# STATUS

Date: 2026-02-03

## Current state
- Project scaffolding is in place (API, training stub, Dagster defs, scripts, tests, Docker).
- [`docker-start.sh`](../docker-start.sh) refactored: function-based with CLI and interactive menu (`--menu`).
- Notebook infrastructure in place: templates, troubleshooting guide in [`notebooks/`](../notebooks/).
- Documentation in [`docs/`](../docs/): API, development, data pipeline, model development.
- Data science deps (`seaborn`, `numpy`, `scikit-learn`, `joblib`) added and synced.
- All AI artifacts in [`.ai/`](.) — skills proposal in [`SKILLS.md`](SKILLS.md).

## Known issues
- direnv hook may point to old Homebrew path on some machines — run `direnv allow` manually if needed.
- Docker images need rebuild (`--no-cache`) to pick up new deps.
- Container smoke test pending after `docker-start.sh` changes.

## Doc gaps
- [`docs/architecture.md`](../docs/architecture.md)
- [`docs/orchestration.md`](../docs/orchestration.md)
- [`docs/deployment.md`](../docs/deployment.md)

## Next priorities

### P0
- Run container smoke test (`/health`, `/predict`)
- Rebuild Docker images with `--no-cache`

### P1
- Decide dataset + problem statement
- Implement real data pipeline (sklearn `fetch_*` or other)
- Training script: 2+ models + tuning → `models/model.joblib`, `reports/metrics.json`
- Wire Dagster assets to data/feature/train/eval
- Update FastAPI `/predict` with real model

### P2
- Create EDA notebook from template
- Add ruff config
- Implement first skills: `/experiment`, `/eda`
