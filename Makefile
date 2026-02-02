.PHONY: setup lint format test train serve docker-build docker-up

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

docker-build:
	docker build -t mymlzoomcamp2025:latest .

docker-up:
	docker compose up --build
