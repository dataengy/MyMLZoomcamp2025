# Development Guide

Guide for local development, testing, and contributions.

## Prerequisites

- Python 3.13+
- [uv](https://github.com/astral-sh/uv) - Python package manager
- [just](https://github.com/casey/just) - Command runner (optional)
- [direnv](https://direnv.net/) - Environment management (optional)
- Docker & Docker Compose - For containerized services

## Initial Setup

### 1. Clone and Setup

```bash
git clone <repository-url>
cd MyMLZoomcamp2025
./scripts/setup.sh
```

With direnv:
```bash
ALLOW_DIRENV=1 ./scripts/setup.sh
```

### 2. Configuration

Copy environment template:
```bash
cp config/.env.demo config/.env
```

Edit [`config/.env`](../config/.env) with your settings:
- `LOG_LEVEL` - Logging level (DEBUG, INFO, WARNING, ERROR)
- `JUPYTER_TOKEN` - Jupyter Lab security token
- `STREAMLIT_DATA_PATH` - Data path for Streamlit

### 3. Verify Installation

```bash
make test
```

## Development Workflow

### Code Style

The project uses:
- **ruff** - Fast linter and formatter
- **pre-commit** - Git hooks for automated checks

Install pre-commit hooks:
```bash
pre-commit install
```

Format code:
```bash
make format
```

Run linter:
```bash
make lint
```

### Testing

Run all tests:
```bash
make test
```

Run specific tests:
```bash
pytest tests/test_api.py -v
pytest tests/test_training_artifacts.py -k "test_name"
```

Fast tests (skip slow tests):
```bash
just test-fast
```

Test with coverage:
```bash
pytest --cov=src --cov-report=html
open htmlcov/index.html
```

### Running Services

#### API Server
```bash
make serve
# or with auto-reload
uvicorn src.api.main:app --reload
```

#### Dagster
```bash
make run-dags
# Access UI at http://localhost:3000
```

#### Streamlit
```bash
make streamlit
# Access UI at http://localhost:8501
```

#### Jupyter
```bash
make jupyter
# Access at http://localhost:8888
```

### Docker Development

Build and run:
```bash
make docker-build
make docker-up
```

Interactive menu:
```bash
./docker-start.sh --menu
```

Run specific service:
```bash
./docker-start.sh -d api
```

Shell into container:
```bash
./docker-start.sh -i api
```

## Project Structure

See [architecture.md](architecture.md) for detailed architecture.

```
.
├── src/              # Source code
│   ├── api/          # FastAPI application
│   ├── dags/         # Dagster assets
│   ├── training/     # Model training
│   └── ui/           # Streamlit UI
├── scripts/          # Utility scripts
│   ├── data_tools/   # Data processing
│   └── utils/        # Shell utilities
├── tests/            # Test suite
├── notebooks/        # Jupyter notebooks
├── docs/             # Documentation
├── config/           # Configuration files
├── data/             # Data storage
├── models/           # Saved models
└── .run/             # Runtime outputs (reports, logs, dagster, venv)
```

## Common Tasks

### Add a New Python Dependency

```bash
uv add package-name
# or for dev dependencies
uv add --dev package-name
```

### Add a New Make Target

Edit [`Makefile`](../Makefile):
```makefile
my-target:
	@echo "Running my target"
	python scripts/my_script.py
```

### Add a New Just Recipe

Edit [`Justfile`](../Justfile):
```just
# My recipe with arguments
my-recipe ARG1 ARG2:
    echo "Running {{ARG1}} {{ARG2}}"
    python scripts/my_script.py {{ARG1}} {{ARG2}}
```

### Add a New Test

Create test file in `tests/`:
```python
# tests/test_my_feature.py
import pytest

def test_my_function():
    result = my_function()
    assert result == expected_value
```

## Troubleshooting

### Import Errors

Ensure PYTHONPATH is set:
```bash
export PYTHONPATH=src
# or use direnv
```

### Docker Issues

Clean docker environment:
```bash
docker compose -f deploy/docker-compose.yml down -v
docker system prune -f
```

### Environment Issues

Reset virtual environment:
```bash
rm -rf .run/.venv
./scripts/setup.sh
```

## Contributing

1. Create a feature branch
2. Make changes
3. Run tests and linting
4. Commit with descriptive messages
5. Create pull request

## See Also

- [Architecture](architecture.md) - System design
- [Testing Guide](#testing) - Testing best practices
- [API Reference](api.md) - API documentation
- [Deployment](deployment.md) - Production deployment
