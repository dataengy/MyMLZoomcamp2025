# CHANGELOG

## 2026-02-03
- Merged root `AGENTS.md` → `.ai/AGENTS.md`; consolidated all AI artifacts into `.ai/`.
- Converted all file paths in `.md` files to hyperlinks.
- Refactored `docker-start.sh`: function-based architecture, CLI, interactive menu (`--menu`).
- Created `notebooks/` infrastructure: `README.md`, `TROUBLESHOOTING.md`, `eda_template.ipynb`, `experiment_template.ipynb`.
- Created `docs/`: `README.md`, `api.md`, `development.md`, `data_pipeline.md`, `model_development.md`.
- Fixed `ModuleNotFoundError: seaborn` — added `seaborn`, `numpy`, `scikit-learn`, `joblib` to deps, `uv sync`'d.
- Created `.ai/SKILLS.md` with 10 proposed skills (DS/ML/MLOps/DE/QA).
- Merged `SESSION_SUMMARY.md` → `STATUS.md`; then split history into `CHANGELOG.md`.

## 2026-02-02
- Scaffolded API, training stub, Dagster definitions, and Docker workflow.
- Added data download/processing scripts and simple data/ML test scripts.
- Added baseline tests for API, data scripts, training artifacts, and Docker (opt-in).
- Added repo status and agent guidelines.
