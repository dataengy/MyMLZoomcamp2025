.PHONY: setup lint format test train serve run-dags docker-build docker-up data data-download data-process data-test ml-test evaluate deploy-local full-pipeline

setup:
	./scripts/setup.sh

lint:
	ruff check .

format:
	ruff format .

test:
	@if ! uv run python -c "import fastapi, pandas, dagster" >/dev/null 2>&1; then \
		echo "Missing test deps. Syncing..."; \
		uv sync --frozen; \
	fi
	uv run pytest -q

train:
	uv run python src/training/train.py

serve:
	PYTHONPATH=src uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

run-dags:
	@if ! uv run python -c "import dagster_webserver" >/dev/null 2>&1; then \
		echo "Missing dagster-webserver. Syncing deps..."; \
		uv sync; \
	fi
	@if uv run python -c "import shutil; raise SystemExit(0 if shutil.which('dg') else 1)" >/dev/null 2>&1; then \
		PYTHONPATH=src uv run dg dev -m dags --host 0.0.0.0 --port 3000; \
	else \
		PYTHONPATH=src uv run dagster dev -m dags --host 0.0.0.0 --port 3000; \
	fi

docker-build:
	docker build -t mymlzoomcamp2025:latest .

docker-up:
	docker compose up --build

# Pipeline steps
data:
	@bash -c 'source scripts/Makefile-utils.sh && run_data'

data-download:
	uv run python scripts/download_data.py

data-process:
	uv run python scripts/process_data.py

data-test:
	uv run python scripts/simple_data_test.py

ml-test:
	uv run python scripts/simple_ml_test.py

evaluate:
	uv run python src/training/evaluate.py

deploy-local:
	@echo "Local deploy placeholder. Use 'make serve' or 'make docker-up' to run the API."

full-pipeline: data train evaluate deploy-local
	@echo "Full pipeline executed"
