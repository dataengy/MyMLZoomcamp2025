# Mirror Makefile targets using just recipes.

# Data loader environment (override on CLI: `just data DATA_SOURCE=...`)
export DATA_SOURCE := ""
export DATA_OUTPUT := ""
export DATA_COLUMNS := ""
export DATA_NROWS := ""
export DATA_FORMAT := ""
export DATA_OUTPUT_FORMAT := ""
export DATA_CACHE_DIR := ""

setup:
	uv sync
	direnv allow && direnv reload
	git remote -v

lint:
	ruff check .

format:
	ruff format .

test:
	uv run pytest -q

train:
	PYTHONPATH=src python src/training/train.py

serve:
	PYTHONPATH=src uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

run-dags:
	@if uv run python -c "import shutil; raise SystemExit(0 if shutil.which('dg') else 1)" >/dev/null 2>&1; then \
		PYTHONPATH=src uv run dg dev -m dags --host 0.0.0.0 --port 3000; \
	else \
		PYTHONPATH=src uv run dagster dev -m dags --host 0.0.0.0 --port 3000; \
	fi

streamlit:
	STREAMLIT_DATA_PATH=data/processed uv run streamlit run src/ui/streamlit_app.py --server.port 8501

jupyter:
	uv run jupyter lab --ip=0.0.0.0 --port 8888 --no-browser

docker-build:
	docker build -t mymlzoomcamp2025:latest .

docker-up:
	docker compose up --build

up: docker-up

# Pipeline steps
data:
	@if [ -z "{{DATA_SOURCE}}" ]; then \
		echo "Set DATA_SOURCE to a URL or local path. Examples:"; \
		echo "  just data DATA_SOURCE=data/raw/sample.csv DATA_OUTPUT=data/processed/sample.csv"; \
		echo "  just data DATA_SOURCE=https://example.com/yellow_tripdata_2024-01.parquet DATA_COLUMNS=tpep_pickup_datetime,tpep_dropoff_datetime,trip_distance,fare_amount DATA_NROWS=100000 DATA_OUTPUT=data/processed/yellow_2024-01.parquet"; \
		exit 2; \
	fi
	bash -c 'source scripts/Makefile-utils.sh && run_data'

data-download:
	uv run python scripts/download_data.py

data-process:
	uv run python scripts/process_data.py

data-test:
	uv run python scripts/simple_data_test.py

ml-test:
	uv run python scripts/simple_ml_test.py

evaluate:
	bash -c 'if [ ! -f reports/metrics.json ]; then echo "Missing reports/metrics.json. Run \"make train\" first."; exit 2; fi; echo "Evaluation report is ready at reports/metrics.json"'

deploy-local:
	echo "Local deploy placeholder. Use \"make serve\" or \"make docker-up\" to run the API."

full-pipeline: data train evaluate deploy-local
	echo "Full pipeline executed"
