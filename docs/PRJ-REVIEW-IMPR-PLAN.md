# Zoomcamp Project Review Improving Plan

Ordered by priority (impact on evaluation criteria divided by implementation difficulty). Sources: `docs/PROJECT-EVALUATION-CRITERIA.md`, `docs/PROJECT-REVIEW.md`.

- [ ] Add cloud deployment coverage with proof: create `docs/deployment.md`, add deployment code/config (e.g., `deploy/cloud/` or `infra/`), and publish a test URL or include a screenshot/video of the running service (Criteria 9).
- [ ] Expand EDA to be extensive: add missing-value analysis, target distribution/outliers, feature relationships, and a simple feature-importance view, then save plots to `reports/eda/` and summarize findings in `README.md` (Criteria 2).
- [ ] Make the multi-model + tuning story explicit: record which models were trained, the tuned hyperparameters, and the resulting metrics in `reports/metrics.json`, then surface a short summary table in `README.md` (Criteria 3).
- [ ] Add a quick “training artifacts” note linking to `src/training/train.py` and `reports/metrics.json` in `docs/model_development.md` to make the training evidence obvious during review (Criteria 3, 4).
