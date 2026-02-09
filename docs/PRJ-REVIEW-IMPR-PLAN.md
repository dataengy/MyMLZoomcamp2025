# Zoomcamp Project Review Improving Plan

Ordered by priority (impact on evaluation criteria divided by implementation difficulty).

- [ ] Expand EDA to be extensive: add missing-value analysis, target distribution/outliers, feature relationships, and a simple feature-importance view, then save plots to `reports/eda/` and summarize findings in `README.md` (Criteria 2).
- [ ] Add explicit reproducibility steps in `README.md` using existing `just`/`make` commands to download, process, train, and evaluate data, including the dataset source link and expected output artifacts (Criteria 5).
- [ ] Add a concrete API deployment verification example in `README.md` or `docs/api.md` with a `curl` request and sample response payload to show the service works end-to-end (Criteria 6).
- [ ] Add explicit Docker build and run instructions (not just compose) in `README.md`, including the image tag and port mapping, and mention `docker compose` as an alternative (Criteria 8).
- [ ] Clarify dependency and environment management in `README.md`: how `uv` creates/uses `.run/.venv`, how to activate it, and how to install deps (Criteria 7).
- [ ] Add a short “model training results” section with metrics and chosen hyperparameters, linking to `reports/metrics.json`, so the multiple-model + tuning evidence is visible (Criteria 3).
- [ ] Add a one-liner in the EDA notebook or `notebooks/README.md` that points to `src/training/train.py` as the exported training script and the `make train` command (Criteria 4).
- [ ] Enrich the problem description with who uses the model, how predictions are consumed, and success criteria (e.g., MAE target) in `README.md` (Criteria 1).
- [ ] Add cloud deployment coverage: create `docs/deployment.md` with step-by-step instructions, include deployment code/config (e.g., `deploy/cloud/`), and provide a public test URL or screenshot/video of the running service (Criteria 9).
