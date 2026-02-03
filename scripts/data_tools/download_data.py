#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from urllib.parse import urljoin
from urllib.request import Request, urlopen

from loguru import logger

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_PATH = PROJECT_ROOT / "src"
if str(SRC_PATH) not in sys.path:
    sys.path.insert(0, str(SRC_PATH))

from config.logging import configure_logging  # noqa: E402

NYC_TAXI_BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/"
PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_DIR = PROJECT_ROOT / "data" / "raw"
DATA_TYPES = ["yellow_tripdata", "green_tripdata", "fhv_tripdata"]
DEFAULT_DATA_TYPE = "yellow_tripdata"
DEFAULT_YEAR = 2024
DEFAULT_MONTHS = [1, 2, 3]


def get_data_url(
    data_type: str, year: int, month: int, base_url: str = NYC_TAXI_BASE_URL
) -> str:
    filename = f"{data_type}_{year}-{month:02d}.parquet"
    return urljoin(base_url, filename)


def download_file(url: str, filepath: Path) -> bool:
    logger.debug("Downloading {} -> {}", url, filepath)
    filepath.parent.mkdir(parents=True, exist_ok=True)
    request = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=300) as response, filepath.open("wb") as handle:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            handle.write(chunk)
    return True


def resolve_months(months: list[int], sample: bool) -> list[int]:
    if not months:
        raise ValueError("Months list cannot be empty.")
    return [months[0]] if sample else months


def download_files(
    data_type: str,
    year: int,
    months: list[int],
    output_dir: Path,
    force: bool,
    base_url: str = NYC_TAXI_BASE_URL,
    downloader=download_file,
) -> tuple[list[Path], list[Path]]:
    output_dir.mkdir(parents=True, exist_ok=True)
    downloaded: list[Path] = []
    skipped: list[Path] = []
    logger.debug(
        "Download config data_type={} year={} months={} output_dir={} force={}",
        data_type,
        year,
        months,
        output_dir,
        force,
    )
    for month in months:
        url = get_data_url(data_type, year, month, base_url=base_url)
        filename = Path(url).name
        filepath = output_dir / filename
        if filepath.exists() and not force:
            logger.debug("Skipping existing file: {}", filepath)
            skipped.append(filepath)
            continue
        downloader(url, filepath)
        downloaded.append(filepath)
    return downloaded, skipped


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Download NYC Taxi trip data")
    parser.add_argument(
        "--data-type",
        choices=DATA_TYPES,
        default=DEFAULT_DATA_TYPE,
        help=f"Type of taxi data to download (default: {DEFAULT_DATA_TYPE})",
    )
    parser.add_argument(
        "--year",
        type=int,
        default=DEFAULT_YEAR,
        help=f"Year to download (default: {DEFAULT_YEAR})",
    )
    parser.add_argument(
        "--months",
        nargs="+",
        type=int,
        default=DEFAULT_MONTHS,
        help=f"Months to download (default: {DEFAULT_MONTHS})",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help="Output directory for downloaded files",
    )
    parser.add_argument(
        "--sample",
        action="store_true",
        help="Download only one month for testing",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Force re-download even if file exists",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    configure_logging()
    args = parse_args(argv)
    logger.debug("Parsed args: {}", args)
    months = resolve_months(args.months, args.sample)
    downloaded, skipped = download_files(
        data_type=args.data_type,
        year=args.year,
        months=months,
        output_dir=args.output_dir,
        force=args.force,
    )
    if not downloaded and not skipped:
        logger.warning("No files downloaded.")
        return 1
    if downloaded:
        logger.info("Downloaded {} new files to {}", len(downloaded), args.output_dir)
    if skipped:
        logger.info("Skipped {} existing files in {}", len(skipped), args.output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
