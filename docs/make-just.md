# Makefile guide

Use the `Makefile` for the main, common workflows. Targets are designed to be quick, standard entry points.

## Common targets

- `make setup` — bootstrap tooling and deps
- `make env-check` — verify `.env` matches `.env.demo`
- `make doctor` — run project health checks
- `make clean` — remove caches and build artifacts
- `make lint` — run linters (ruff + pre-commit checks)
- `make format` — auto-format code and configs
- `make test` — run unit tests
- `make train` — train the default model pipeline
- `make serve` — start FastAPI dev server
- `make dagster` — start Dagster web UI
- `make run-dags` — run orchestrator entrypoint
- `make streamlit` — start Streamlit UI
- `make jupyter` — start Jupyter Lab
- `make docker-up` — docker compose up --build
- `make qa-all` — full QA suite
- `make all` — lint + test

# Justfile guide

Use the `Justfile` for more specific or advanced workflows. It also provides wrappers for the Makefile targets.

## Specific / advanced targets

- `just setup-dev` — dev environment bootstrap helpers
- `just data` — load data (requires `DATA_SOURCE`; optional `DATA_COLUMNS`, `DATA_NROWS`, `DATA_OUTPUT`)
- `just data-download` — download raw data
- `just data-process` — process raw data to clean format
- `just data-test` — quick data sanity test
- `just ml-test` — quick ML pipeline sanity test
- `just evaluate` — evaluate trained model
- `just full-pipeline` — data → train → evaluate → deploy (local)
- `just test-fast` — quick pytest run
- `just lint-notebooks` / `just nb-lint` — lint notebooks
- `just test-notebooks` / `just nb-test` — execute notebooks
- `just test-notebooks-sanitized` / `just nb-check` — check sanitized notebooks
- `just nb-strip` / `just nb-fmt` — strip outputs / format notebooks
- `just all-lint-test` — lint + test in parallel (faster feedback)

## Makefile mirrors (via just)

These recipes call the Makefile targets directly:

- `just make-setup` — runs `make setup` (bootstrap tooling and deps)
- `just make-env-check` — runs `make env-check` (verify `.env` matches `.env.demo`)
- `just make-doctor` — runs `make doctor` (project health checks)
- `just make-clean` — runs `make clean` (remove caches/artifacts)
- `just make-lint` — runs `make lint` (ruff + pre-commit checks)
- `just make-format` — runs `make format` (auto-format code/configs)
- `just make-test` — runs `make test` (unit tests)
- `just make-train` — runs `make train` (train default model)
- `just make-serve` — runs `make serve` (start FastAPI dev server)
- `just make-dagster` — runs `make dagster` (start Dagster UI)
- `just make-run-dags` — runs `make run-dags` (orchestrator entrypoint)
- `just make-streamlit` — runs `make streamlit` (start Streamlit UI)
- `just make-jupyter` — runs `make jupyter` (start Jupyter Lab)
- `just make-docker-up` — runs `make docker-up` (compose up --build)
- `just make-qa-all` — runs `make qa-all` (full QA suite)
- `just make-all` — runs `make all` (lint + test)

## Agent Justfiles (Claude + Codex)

- `just -f scripts/claude/Justfile context`
- `just -f scripts/claude/Justfile install-skills`
- `just -f scripts/codex/Justfile install-skills`

See `scripts/claude/README.md` and `scripts/codex/README.md` for details.
