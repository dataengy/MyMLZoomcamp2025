from __future__ import annotations

from pathlib import Path

from scripts.data_tools import load_data


def test_infer_format_handles_common_extensions(tmp_path: Path) -> None:
    assert load_data._infer_format(tmp_path / "file.csv") == "csv"
    assert load_data._infer_format(tmp_path / "file.json") == "json"
    assert load_data._infer_format(tmp_path / "file.parquet") == "parquet"
    assert load_data._infer_format(tmp_path / "file.csv.gz") == "csv"


def test_normalize_columns_splits_and_strips() -> None:
    assert load_data._normalize_columns("a, b , ,c") == ["a", "b", "c"]
    assert load_data._normalize_columns("") is None


def test_resolve_source_local_path(tmp_path: Path) -> None:
    source = tmp_path / "input.csv"
    source.write_text("a,b\n1,2\n")
    resolved = load_data._resolve_source(str(source), tmp_path / "cache", False)
    assert resolved == source
