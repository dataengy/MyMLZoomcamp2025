from __future__ import annotations

import importlib
import sys
import types
from pathlib import Path

import pandas as pd


def _install_dummy_streamlit() -> types.ModuleType:
    class DummyContext:
        def __enter__(self):
            return self

        def __exit__(self, exc_type, exc, tb):
            return False

    module = types.ModuleType("streamlit")

    def _noop(*_args, **_kwargs):
        return None

    def _columns(*_args, **_kwargs):
        return (DummyContext(), DummyContext())

    def _selectbox(_label, options, index=0, format_func=None):
        _ = format_func
        return options[index]

    def _checkbox(*_args, **_kwargs):
        return False

    def _slider(*_args, **_kwargs):
        return 5

    def _stop():
        raise AssertionError("st.stop() called unexpectedly")

    module.set_page_config = _noop
    module.title = _noop
    module.caption = _noop
    module.columns = _columns
    module.subheader = _noop
    module.write = _noop
    module.info = _noop
    module.stop = _stop
    module.selectbox = _selectbox
    module.checkbox = _checkbox
    module.slider = _slider
    module.dataframe = _noop

    return module


def test_streamlit_helpers(monkeypatch, tmp_path: Path) -> None:
    df = pd.DataFrame(
        {
            "trip_distance": [1.2, 3.4],
            "fare_amount": [10.0, 20.0],
            "vendor": ["A", "B"],
        }
    )
    csv_path = tmp_path / "sample.csv"
    parquet_path = tmp_path / "sample.parquet"
    df.to_csv(csv_path, index=False)
    df.to_parquet(parquet_path, index=False)

    monkeypatch.setenv("STREAMLIT_DATA_PATH", str(tmp_path))
    monkeypatch.setenv("STREAMLIT_DEFAULT_FILE", "sample.csv")
    monkeypatch.setenv("STREAMLIT_SAMPLE_ROWS", "10")

    dummy_streamlit = _install_dummy_streamlit()
    monkeypatch.setitem(sys.modules, "streamlit", dummy_streamlit)

    sys.modules.pop("ui.streamlit_app", None)
    module = importlib.import_module("ui.streamlit_app")

    files = module._list_data_files(tmp_path)
    assert files == sorted([csv_path, parquet_path])

    csv_df = module._read_data(csv_path)
    parquet_df = module._read_data(parquet_path)
    assert len(csv_df) == len(df)
    assert len(parquet_df) == len(df)
