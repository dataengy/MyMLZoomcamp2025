.PHONY: setup lint format test train serve run-dags streamlit jupyter docker-build docker-up up

LOG_LEVEL ?= debug
export LOG_LEVEL

setup:
	./scripts/setup.sh

lint:
	uv run ruff check .
	pre-commit run --all-files shellcheck
	pre-commit run --all-files checkmake
	pre-commit run --all-files yamllint

format:
	uv run ruff format .
	pre-commit run --all-files shfmt
	pre-commit run --all-files yamlfmt
	pre-commit run --all-files just-fmt
	pre-commit run --all-files end-of-file-fixer
	pre-commit run --all-files trailing-whitespace

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

streamlit:
	STREAMLIT_DATA_PATH=data/processed uv run streamlit run src/ui/streamlit_app.py --server.port 8501

jupyter:
	uv run jupyter lab --ip=0.0.0.0 --port 8888 --no-browser

docker-build:
	docker build -t mymlzoomcamp2025:latest .

docker-up:
	docker compose up --build

up: docker-up
