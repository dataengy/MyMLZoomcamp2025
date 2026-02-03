# TODO

Prioritized by impact/complexity (highest first).

- [x] P0: Scaffold repository structure per prompt ([`src/api`](../src/api), [`src/training`](../src/training), [`notebooks`](../notebooks), [`reports`](../reports), [`models`](../models)) with placeholder files.
- [x] P0: Create minimal FastAPI app with `/health` and `/predict` (mock prediction for now) to validate container wiring.
- [x] P0: Create minimal Dagster assets/job that runs no-op steps (or dummy data flow) to validate orchestration wiring.
- [x] P0: Add [`Makefile`](../Makefile) targets (`setup`, `lint`, `train`, `serve`, `docker-build`, `docker-up`).
- [x] P0: Add Dockerfile + docker-compose, [`.env`](../config/.env)/[`.env.demo`](../config/.env.demo), and [`docker-run.sh`](../docker-run.sh).
- [ ] P0: Run container smoke test after next Docker change (confirm `/health` and `/predict`).

- [x] P1: Add utility scripts ([`download_data.py`](../scripts/data_tools/download_data.py), [`process_data.py`](../scripts/data_tools/process_data.py), [`simple_data_test.py`](../tests/bash/simple_data_test.py), [`simple_ml_test.py`](../tests/bash/simple_ml_test.py)).
- [x] P1: Add basic tests for API, load_data, training artifacts, and docker (opt-in).
- [x] P1: Add tests for [`process_data.py`](../scripts/data_tools/process_data.py), [`simple_data_test.py`](../tests/bash/simple_data_test.py), [`simple_ml_test.py`](../tests/bash/simple_ml_test.py).
- [ ] P1: Decide dataset choice and problem statement (confirm target, task type, expected inputs/outputs).
- [ ] P1: Implement real data fetch/prepare pipeline (sklearn fetch_* or other public source).
- [ ] P1: Implement training script with 2 model families + tuning; save [`models/model.joblib`](../models/) and [`reports/metrics.json`](../reports/).
- [ ] P1: Implement evaluation utilities and metrics reporting.
- [ ] P1: Wire Dagster assets to real data/feature/train/eval steps.
- [ ] P1: Update FastAPI `/predict` to load real model and validate request schema.

- [ ] P2: Create EDA notebook with required analyses and conclusions.
- [x] P2: Update [`README`](../README.md) with usage, local run, Docker, Dagster, and Make/Just split.
- [ ] P2: Add ruff config and ensure formatting/linting passes.

- [x] P3: Add doctor script to debug GitHub push issues.
- [ ] P3: Add basic tests for setup script behavior (optional).
