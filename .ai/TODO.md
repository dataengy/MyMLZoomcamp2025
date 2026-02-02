# TODO

Prioritized by impact/complexity (highest first).

- [ ] P0: Scaffold repository structure per prompt (src/api, src/training, src/orchestration, notebooks, reports, models) with placeholder files.
- [ ] P0: Create minimal FastAPI app with `/health` and `/predict` (mock prediction for now) to validate container wiring.
- [x] P0: Create minimal Dagster assets/job that runs no-op steps (or dummy data flow) to validate orchestration wiring.
- [x] P0: Add Dockerfile and (optional) docker-compose to run API (and Dagster dev if included).
- [ ] P0: Add Makefile targets (`setup`, `lint`, `train`, `serve`, `dagster`, `docker-build`, `docker-up`).
- [ ] P0: Run `make docker-build` and `make docker-up` to confirm container builds and endpoints respond (no dataset yet).

- [ ] P1: Define dataset choice and problem statement (confirm target, task type, expected inputs/outputs).
- [ ] P1: Implement data fetch/prepare pipeline (sklearn fetch_* or other public source).
- [ ] P1: Implement training script with 2 model families + tuning; save `models/model.joblib` and `reports/metrics.json`.
- [ ] P1: Implement evaluation utilities and metrics reporting.
- [ ] P1: Wire Dagster assets to real data/feature/train/eval steps.
- [ ] P1: Update FastAPI `/predict` to load real model and validate request schema.

- [ ] P2: Create EDA notebook with required analyses and conclusions.
- [ ] P2: Update README with usage, local run, Docker, Dagster, and project criteria mapping.
- [ ] P2: Add ruff config and ensure formatting/linting passes.

- [x] P3: Add basic tests (API health, predict schema, training artifact generation) if desired.
