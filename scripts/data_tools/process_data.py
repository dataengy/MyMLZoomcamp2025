#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from collections.abc import Iterable
from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[2]
SRC_PATH = PROJECT_ROOT / "src"
if str(SRC_PATH) not in sys.path:
    sys.path.insert(0, str(SRC_PATH))

from config.logging import configure_logging, log  # noqa: E402


def _load_files(files: Iterable[Path], fmt: str) -> pd.DataFrame:
    frames: list[pd.DataFrame] = []
    files = list(files)
    log.debug("Loading {} files with format={}", len(files), fmt)
    for path in files:
        if fmt == "parquet":
            import duckdb

            with duckdb.connect() as conn:
                frames.append(conn.execute("SELECT * FROM read_parquet(?)", [str(path)]).df())
        elif fmt == "csv":
            frames.append(pd.read_csv(path))
        else:
            raise ValueError(f"Unsupported input format: {fmt}")
    if not frames:
        raise ValueError("No input files found.")
    return pd.concat(frames, ignore_index=True)


def _clean_data(df: pd.DataFrame) -> pd.DataFrame:
    log.debug("Cleaning data with {} rows", len(df))
    if "tpep_pickup_datetime" in df.columns and "tpep_dropoff_datetime" in df.columns:
        df["tpep_pickup_datetime"] = pd.to_datetime(df["tpep_pickup_datetime"])
        df["tpep_dropoff_datetime"] = pd.to_datetime(df["tpep_dropoff_datetime"])
        df["trip_duration"] = (
            df["tpep_dropoff_datetime"] - df["tpep_pickup_datetime"]
        ).dt.total_seconds()
    else:
        raise ValueError("Missing pickup/dropoff datetime columns.")

    if "passenger_count" in df.columns:
        before = len(df)
        df = df[df["passenger_count"].between(1, 8)]
        log.debug("Filter passenger_count: {} -> {}", before, len(df))
    if "trip_distance" in df.columns:
        before = len(df)
        df = df[df["trip_distance"].between(0.01, 100)]
        log.debug("Filter trip_distance: {} -> {}", before, len(df))
    if "fare_amount" in df.columns:
        before = len(df)
        df = df[df["fare_amount"].between(0.01, 1000)]
        log.debug("Filter fare_amount: {} -> {}", before, len(df))
    if "trip_duration" in df.columns:
        before = len(df)
        df = df[df["trip_duration"].between(30, 10800)]
        log.debug("Filter trip_duration: {} -> {}", before, len(df))
    return df


def _engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    log.debug("Engineering features for {} rows", len(df))
    df["pickup_hour"] = df["tpep_pickup_datetime"].dt.hour
    df["pickup_weekday"] = df["tpep_pickup_datetime"].dt.weekday
    df["pickup_is_weekend"] = (df["pickup_weekday"] >= 5).astype(int)

    df["hour_category"] = pd.cut(
        df["pickup_hour"],
        bins=[0, 6, 12, 18, 24],
        labels=["Night", "Morning", "Afternoon", "Evening"],
        include_lowest=True,
    )

    df["distance_category"] = pd.cut(
        df["trip_distance"],
        bins=[0, 2, 5, 10, float("inf")],
        labels=["Short", "Medium", "Long", "Very_Long"],
        include_lowest=True,
    )

    df["speed_mph"] = (df["trip_distance"] / (df["trip_duration"] / 3600)).round(2)
    df["speed_mph"] = df["speed_mph"].clip(0, 100)

    if "PULocationID" in df.columns:
        airport_locations = [132, 138, 161]
        df["is_airport_pickup"] = df["PULocationID"].isin(airport_locations).astype(int)
    if "DOLocationID" in df.columns:
        airport_locations = [132, 138, 161]
        df["is_airport_dropoff"] = df["DOLocationID"].isin(airport_locations).astype(int)

    rush_hours = [7, 8, 9, 17, 18, 19]
    df["is_rush_hour"] = df["pickup_hour"].isin(rush_hours).astype(int)
    return df


def _select_features(df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    feature_columns = [
        "trip_distance",
        "passenger_count",
        "pickup_hour",
        "pickup_weekday",
        "pickup_is_weekend",
        "is_rush_hour",
        "speed_mph",
        "PULocationID",
        "DOLocationID",
        "is_airport_pickup",
        "is_airport_dropoff",
    ]

    feature_columns = [col for col in feature_columns if col in df.columns]
    model_df = df[feature_columns + ["trip_duration"]].copy()
    model_df = model_df.dropna()
    log.debug("Selected {} features for {} rows", len(feature_columns), len(model_df))
    return model_df, feature_columns


def _write_outputs(df: pd.DataFrame, features: list[str], output_dir: Path, fmt: str) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    data_path = output_dir / f"processed_data.{fmt}"
    if fmt == "parquet":
        df.to_parquet(data_path, index=False)
    elif fmt == "csv":
        df.to_csv(data_path, index=False)
    else:
        raise ValueError(f"Unsupported output format: {fmt}")

    features_path = output_dir / "features.txt"
    features_path.write_text("\n".join(features) + "\n")

    summary_path = output_dir / "data_summary.txt"
    summary_path.write_text(
        "\n".join(
            [
                "Dataset Summary",
                "===============",
                f"Total samples: {len(df)}",
                f"Features: {len(features)}",
                "Target: trip_duration",
            ]
        )
        + "\n"
    )
    log.info("Wrote processed data to {}", output_dir)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Process NYC Taxi data for ML")
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=Path("data/raw"),
        help="Input directory with raw files",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("data/processed"),
        help="Output directory for processed data",
    )
    parser.add_argument(
        "--sample-size",
        type=int,
        help="Sample N records for testing (use all data if not specified)",
    )
    parser.add_argument(
        "--input-format",
        choices=["parquet", "csv"],
        help="Override input format detection",
    )
    parser.add_argument(
        "--output-format",
        choices=["parquet", "csv"],
        default="csv",
        help="Output format for processed data",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    configure_logging()
    args = parse_args(argv)
    log.debug("Parsed args: {}", args)
    parquet_files = list(args.input_dir.glob("*.parquet"))
    csv_files = list(args.input_dir.glob("*.csv"))

    if args.input_format:
        fmt = args.input_format
        files = parquet_files if fmt == "parquet" else csv_files
    elif parquet_files:
        fmt = "parquet"
        files = parquet_files
    else:
        fmt = "csv"
        files = csv_files

    if not files:
        log.warning("No input files found in {}", args.input_dir)
        return 1

    df = _load_files(files, fmt)
    if args.sample_size and args.sample_size < len(df):
        df = df.sample(n=args.sample_size, random_state=42)
        log.debug("Sampled {} records", args.sample_size)

    df = _clean_data(df)
    df = _engineer_features(df)
    model_df, features = _select_features(df)
    _write_outputs(model_df, features, args.output_dir, args.output_format)
    log.info("Processed data saved to {}", args.output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(log.catch(main)())
