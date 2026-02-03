from __future__ import annotations

from pathlib import Path

from scripts.download_data import download_files, get_data_url, resolve_months


def test_get_data_url_formats_month() -> None:
    url = get_data_url("yellow_tripdata", 2024, 1, base_url="https://example.com/")
    assert url.endswith("yellow_tripdata_2024-01.parquet")


def test_resolve_months_sample() -> None:
    months = resolve_months([1, 2, 3], sample=True)
    assert months == [1]


def test_download_files_skips_existing(tmp_path: Path) -> None:
    output_dir = tmp_path / "raw"
    output_dir.mkdir()
    existing = output_dir / "yellow_tripdata_2024-01.parquet"
    existing.write_text("already")

    def fake_downloader(url: str, filepath: Path) -> bool:
        filepath.write_text("downloaded")
        return True

    downloaded, skipped = download_files(
        data_type="yellow_tripdata",
        year=2024,
        months=[1],
        output_dir=output_dir,
        force=False,
        base_url="https://example.com/",
        downloader=fake_downloader,
    )

    assert downloaded == []
    assert skipped == [existing]
    assert existing.read_text() == "already"
