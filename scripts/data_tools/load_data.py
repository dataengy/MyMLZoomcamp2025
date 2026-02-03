#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from collections.abc import Iterable
from pathlib import Path
from typing import TYPE_CHECKING
from urllib.parse import urlparse
from urllib.request import Request, urlopen

if TYPE_CHECKING:
    import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[2]
SRC_PATH = PROJECT_ROOT / "src"
if str(SRC_PATH) not in sys.path:
    sys.path.insert(0, str(SRC_PATH))

from config.logging import configure_logging, log  # noqa: E402

DEFAULT_CACHE_DIR = PROJECT_ROOT / "data" / "raw"


def _is_url(value: str) -> bool:
    parsed = urlparse(value)
    return parsed.scheme in {"http", "https"}


def _infer_format(path: Path) -> str:
    suffixes = [s.lower() for s in path.suffixes]
    if not suffixes:
        raise ValueError(f"Cannot infer format from {path}")
    if suffixes[-1] == ".parquet":
        return "parquet"
    if suffixes[-1] == ".csv":
        return "csv"
    if suffixes[-1] == ".json":
        return "json"
    if suffixes[-1] in {".gz", ".zip"} and len(suffixes) >= 2:
        if suffixes[-2] == ".csv":
            return "csv"
        if suffixes[-2] == ".json":
            return "json"
    raise ValueError(f"Unsupported file extension: {''.join(suffixes[-2:])}")


def _download(url: str, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request) as response, dest.open("wb") as f:
        total = int(response.headers.get("Content-Length", 0))
        downloaded = 0
        chunk_size = 1024 * 1024
        while True:
            chunk = response.read(chunk_size)
            if not chunk:
                break
            f.write(chunk)
            downloaded += len(chunk)
            _render_progress(downloaded, total)
    _finish_progress(downloaded, total)
    return dest


def _resolve_source(source: str, cache_dir: Path, force_download: bool) -> Path:
    if _is_url(source):
        filename = Path(urlparse(source).path).name
        if not filename:
            raise ValueError("URL must point to a file path")
        dest = cache_dir / filename
        if dest.exists() and not force_download:
            log.debug("Using cached file: {}", dest)
            return dest
        log.info("Downloading: {}", source)
        return _download(source, dest)
    return Path(source)


def _normalize_columns(value: str | None) -> list[str] | None:
    if not value:
        return None
    items = [item.strip() for item in value.split(",")]
    return [item for item in items if item]


def _read_dataframe(
    path: Path, fmt: str, columns: Iterable[str] | None, nrows: int | None
) -> pd.DataFrame:
    import pandas as pd

    if fmt == "csv":
        return pd.read_csv(path, usecols=columns, nrows=nrows)
    if fmt == "json":
        return pd.read_json(path, lines=True)
    if fmt == "parquet":
        return pd.read_parquet(path, columns=list(columns) if columns else None)
    raise ValueError(f"Unsupported format: {fmt}")


def _write_dataframe(df: pd.DataFrame, output: Path, fmt: str) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    if fmt == "csv":
        df.to_csv(output, index=False)
        return
    if fmt == "json":
        df.to_json(output, orient="records", lines=True)
        return
    if fmt == "parquet":
        df.to_parquet(output, index=False)
        return
    raise ValueError(f"Unsupported output format: {fmt}")


def _format_columns(columns: list[str]) -> str:
    if len(columns) <= 25:
        return ", ".join(columns)
    return ", ".join(columns[:25]) + " ..."


def _file_size_mb(path: Path) -> float:
    return path.stat().st_size / (1024 * 1024)


def _render_progress(downloaded: int, total: int) -> None:
    if total > 0:
        pct = downloaded / total * 100
        sys.stdout.write(
            f"\rDownloading... {pct:5.1f}% "
            f"({downloaded / (1024 * 1024):.1f} MB / {total / (1024 * 1024):.1f} MB)"
        )
    else:
        sys.stdout.write(f"\rDownloading... {downloaded / (1024 * 1024):.1f} MB")
    sys.stdout.flush()


def _finish_progress(downloaded: int, total: int) -> None:
    if downloaded == 0 and total == 0:
        return
    sys.stdout.write("\n")
    sys.stdout.flush()


def main() -> None:
    configure_logging()
    parser = argparse.ArgumentParser(
        description="Download (optional) and load a dataset such as NYC Taxi parquet/csv files.",
    )
    parser.add_argument(
        "--source",
        required=True,
        help="URL or local file path to the dataset.",
    )
    parser.add_argument(
        "--output",
        help="Optional output path to save the loaded data.",
    )
    parser.add_argument(
        "--format",
        choices=["csv", "parquet", "json"],
        help="Override format inference for the source.",
    )
    parser.add_argument(
        "--output-format",
        choices=["csv", "parquet", "json"],
        help="Override format inference for the output.",
    )
    parser.add_argument(
        "--columns",
        help="Comma-separated list of columns to load.",
    )
    parser.add_argument(
        "--nrows",
        type=int,
        help="Limit number of rows to load.",
    )
    parser.add_argument(
        "--cache-dir",
        default=str(DEFAULT_CACHE_DIR),
        help="Directory for cached downloads (only used for URLs).",
    )
    parser.add_argument(
        "--force-download",
        action="store_true",
        help="Re-download even if the file is already cached.",
    )
    parser.add_argument(
        "--show-head",
        action="store_true",
        help="Print the first 5 rows after loading.",
    )

    args = parser.parse_args()

    cache_dir = Path(args.cache_dir)
    log.info("Source: {}", args.source)
    log.debug("Cache dir: {}", cache_dir)
    source_path = _resolve_source(args.source, cache_dir, args.force_download)
    if not source_path.exists():
        raise FileNotFoundError(f"Source not found: {source_path}")

    fmt = args.format or _infer_format(source_path)
    columns = _normalize_columns(args.columns)
    log.info("Format: {}", fmt)
    if args.output:
        log.info("Output: {}", args.output)
    if columns:
        log.info("Column filter: {}", _format_columns(columns))

    df = _read_dataframe(source_path, fmt, columns, args.nrows)

    log.info("Loaded {} rows x {} columns from {}", len(df), len(df.columns), source_path)
    log.debug("Columns ({}): {}", len(df.columns), _format_columns(list(df.columns)))

    if args.show_head:
        log.debug("Head:\n{}", df.head().to_string(index=False))

    if args.output:
        output_path = Path(args.output)
        out_fmt = args.output_format or _infer_format(output_path)
        _write_dataframe(df, output_path, out_fmt)
        size_mb = _file_size_mb(output_path)
        log.info("Saved data to {} ({:.1f} MB)", output_path, size_mb)


if __name__ == "__main__":
    log.catch(main)()
