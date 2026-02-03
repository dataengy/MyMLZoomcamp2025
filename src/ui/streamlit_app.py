from __future__ import annotations

import os
from pathlib import Path

import pandas as pd
import streamlit as st

DATA_PATH = Path(os.getenv("STREAMLIT_DATA_PATH", "data/processed"))
DEFAULT_FILE = os.getenv("STREAMLIT_DEFAULT_FILE", "")
SAMPLE_ROWS = int(os.getenv("STREAMLIT_SAMPLE_ROWS", "2000"))


def _list_data_files(root: Path) -> list[Path]:
    if not root.exists():
        return []
    files = [p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in {".parquet", ".csv"}]
    return sorted(files)


def _read_data(path: Path) -> pd.DataFrame:
    if path.suffix.lower() == ".parquet":
        return pd.read_parquet(path)
    return pd.read_csv(path)


st.set_page_config(page_title="MLZoomcamp Streamlit", layout="wide")
st.title("MLZoomcamp Streamlit")
st.caption("Explore processed datasets and quick summaries.")

left, right = st.columns([1, 2], gap="large")

with left:
    st.subheader("Dataset")
    st.write(f"Looking in `{DATA_PATH}`.")

    files = _list_data_files(DATA_PATH)
    if not files:
        st.info("No CSV/parquet files found. Add data to the processed folder.")
        st.stop()

    default_index = 0
    if DEFAULT_FILE:
        for idx, path in enumerate(files):
            if path.name == DEFAULT_FILE or str(path) == DEFAULT_FILE:
                default_index = idx
                break

    chosen = st.selectbox(
        "Choose a file",
        files,
        index=default_index,
        format_func=lambda p: p.name,
    )

    st.write("Preview options")
    sample = st.checkbox("Sample rows", value=True)
    nrows = st.slider("Rows to display", min_value=50, max_value=5000, value=500)

with right:
    st.subheader("Preview")
    data = _read_data(chosen)

    if sample and len(data) > SAMPLE_ROWS:
        data = data.sample(SAMPLE_ROWS, random_state=42)

    st.dataframe(data.head(nrows), use_container_width=True, height=520)

    st.subheader("Summary")
    st.write(data.describe(include="all").transpose())
