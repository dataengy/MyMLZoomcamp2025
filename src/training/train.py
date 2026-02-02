from __future__ import annotations

import json
from pathlib import Path


def main() -> None:
    """Placeholder training script until dataset/model are defined."""
    models_dir = Path("models")
    reports_dir = Path("reports")
    models_dir.mkdir(parents=True, exist_ok=True)
    reports_dir.mkdir(parents=True, exist_ok=True)

    # Write placeholder artifacts so downstream wiring can be tested.
    (models_dir / "model.joblib").write_text("placeholder model")
    (reports_dir / "metrics.json").write_text(json.dumps({"status": "placeholder"}))


if __name__ == "__main__":
    main()
