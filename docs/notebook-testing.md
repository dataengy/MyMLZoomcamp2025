# Notebook Testing and Linting

Comprehensive guide for testing and linting Jupyter notebooks in this project.

## Overview

This project uses several tools to ensure notebook quality:

- **nbqa** - Run Python linters/formatters on notebooks (via ruff)
- **nbval** - Test notebook execution with pytest
- **nbstripout** - Strip outputs from notebooks before committing
- **pytest** - Test notebook structure and content

## Quick Start

```bash
# Lint notebooks
just nb-lint

# Format notebooks
just nb-fmt

# Check notebooks are sanitized (no outputs)
just nb-check

# Strip outputs from all notebooks
just nb-strip

# Test notebook execution (can be slow)
just nb-test
```

## Tools and Configuration

### 1. nbqa - Run Linters on Notebooks

**What it does:** Allows running standard Python tools (ruff, mypy, etc.) on Jupyter notebooks.

**Configuration:** `pyproject.toml`
```toml
[tool.nbqa.addopts]
ruff = ["--extend-ignore=E501,F401,F841"]
```

**Usage:**
```bash
# Lint notebooks
uv run nbqa ruff notebooks/

# Format notebooks
uv run nbqa ruff format notebooks/

# Or use convenience scripts
./scripts/notebooks/lint_notebooks.sh
./scripts/notebooks/format_notebooks.sh
```

### 2. nbstripout - Strip Notebook Outputs

**What it does:** Removes cell outputs and execution counts from notebooks.

**Why:** Prevents merge conflicts, reduces repo size, keeps notebooks clean.

**Configuration:** `.nbstripout`
```ini
[metadata]
keep_output = false
keep_count = false

[cell]
keep_output = false
```

**Usage:**
```bash
# Strip single notebook
uv run nbstripout notebooks/my_notebook.ipynb

# Strip all notebooks
./scripts/notebooks/strip_notebooks.sh
# or
just nb-strip
```

### 3. nbval - Test Notebook Execution

**What it does:** Executes notebooks and validates outputs match expected results.

**Configuration:** `pyproject.toml`
```toml
[tool.pytest.ini_options]
markers = [
    "notebook: marks tests for Jupyter notebooks",
]
```

**Usage:**
```bash
# Test all notebooks
./scripts/notebooks/test_notebooks.sh

# Test specific notebook
uv run pytest --nbval notebooks/01_eda.ipynb

# Skip slow notebook tests
uv run pytest -m "not notebook"
```

### 4. pytest - Custom Notebook Tests

**What it does:** Tests notebook structure, metadata, and content.

**Tests:** `tests/test_notebooks.py`
- ✓ Notebooks are sanitized (no outputs)
- ✓ Notebooks have titles in first cell
- ✓ Template notebooks exist

**Usage:**
```bash
# Run all notebook tests
uv run pytest tests/test_notebooks.py -v

# Run only sanitization checks
uv run pytest tests/test_notebooks.py::test_notebook_is_sanitized -v
```

## Pre-commit Hooks

Notebooks are automatically linted and stripped on commit.

**Configuration:** `.pre-commit-config.yaml`

```yaml
- id: nbqa-ruff
  name: nbqa ruff (notebooks)
  entry: uv run nbqa ruff --fix
  language: system
  types: [jupyter]

- id: nbstripout
  name: nbstripout (strip notebook outputs)
  entry: uv run nbstripout
  language: system
  types: [jupyter]
```

**Enable pre-commit:**
```bash
# Install hooks
pre-commit install

# Run manually on all files
pre-commit run --all-files

# Run only on notebooks
pre-commit run --all-files nbqa-ruff
pre-commit run --all-files nbstripout
```

## CI/CD Integration

### GitHub Actions

**File:** `.github/workflows/ci.yml`

```yaml
- name: Lint Notebooks
  run: ./scripts/notebooks/lint_notebooks.sh

- name: Check notebooks are sanitized
  run: ./scripts/notebooks/check_sanitized.sh

- name: Test notebook execution
  run: ./scripts/notebooks/test_notebooks.sh
```

### GitLab CI

**File:** `.gitlab-ci.yml`

```yaml
lint:notebooks:
    script:
        - ./scripts/notebooks/lint_notebooks.sh

test:notebooks-sanitized:
    script:
        - ./scripts/notebooks/check_sanitized.sh

test:notebooks-execution:
    script:
        - ./scripts/notebooks/test_notebooks.sh
```

## Workflow Examples

### Before Committing Notebooks

```bash
# 1. Strip outputs
just nb-strip

# 2. Format code
just nb-fmt

# 3. Check quality
just nb-check

# 4. Commit
git add notebooks/
git commit -m "Add analysis notebook"
```

### Reviewing Notebook Pull Requests

```bash
# Check all notebooks in PR are clean
just nb-check

# Verify notebooks execute successfully
just nb-test

# Lint notebooks
just nb-lint
```

### Fixing Failed Checks

**Problem: "Notebook has outputs"**
```bash
# Strip outputs from specific notebook
uv run nbstripout notebooks/my_notebook.ipynb

# Or strip all
just nb-strip
```

**Problem: "Notebook linting errors"**
```bash
# Auto-fix most issues
uv run nbqa ruff --fix notebooks/

# Format code
uv run nbqa ruff format notebooks/

# Or use convenience command
just nb-fmt
```

**Problem: "Notebook execution failed"**
```bash
# Run notebook interactively to debug
jupyter lab notebooks/failing_notebook.ipynb

# Check kernel and dependencies
make jupyter
```

## Best Practices

### 1. Always Strip Outputs Before Committing

Notebook outputs can be large and cause merge conflicts.

```bash
# Add to your workflow
just nb-strip
git add notebooks/
git commit -m "Update analysis"
```

### 2. Keep Notebooks Small and Focused

- One notebook per analysis step
- Move reusable code to `src/`
- Use templates for consistency

### 3. Add Descriptive Titles

First cell should be markdown with `# Title`:

```markdown
# Exploratory Data Analysis - Customer Segmentation

This notebook analyzes customer behavior patterns...
```

### 4. Use Consistent Naming

- `01_`, `02_`, `03_` - Main analysis sequence
- `exp_` - Experimental notebooks
- `draft_` - Work in progress
- `archive_` - Completed experiments

### 5. Document Assumptions and Decisions

```python
# Assumption: Missing values represent "unknown" category
# Decision: Use median imputation for better handling of outliers
df['age'].fillna(df['age'].median(), inplace=True)
```

## Troubleshooting

### Pre-commit Hook Fails

```bash
# Update dependencies
uv sync

# Re-run hooks manually
pre-commit run --all-files

# Skip hooks temporarily (not recommended)
git commit --no-verify -m "message"
```

### nbval Tests Fail

```bash
# Clear outputs and re-run
just nb-strip
jupyter lab  # Re-execute notebook

# Or skip nbval tests
pytest -m "not notebook"
```

### Notebook Won't Execute in CI

Common causes:
- Missing dependencies in `pyproject.toml`
- Long-running cells (timeout)
- External data dependencies

Solutions:
```bash
# Add dependencies
uv add package-name

# Skip slow notebooks in CI
# Add to notebook first cell:
# pytest.skip("Slow notebook - skip in CI")

# Or mark notebook as slow
# Then run: pytest -m "not slow"
```

## Scripts Reference

All scripts are in `scripts/notebooks/`:

| Script | Purpose |
|--------|---------|
| `lint_notebooks.sh` | Lint notebooks with ruff |
| `format_notebooks.sh` | Format notebooks with ruff |
| `check_sanitized.sh` | Verify no outputs/counts |
| `strip_notebooks.sh` | Remove all outputs |
| `test_notebooks.sh` | Execute notebooks with nbval |

## Just Commands

| Command | Description |
|---------|-------------|
| `just nb-lint` | Lint notebooks |
| `just nb-fmt` | Format notebooks |
| `just nb-test` | Test execution |
| `just nb-check` | Check sanitized |
| `just nb-strip` | Strip outputs |
| `just notebooks-check` | Lint + sanitized |

## References

- [nbqa documentation](https://nbqa.readthedocs.io/)
- [nbval documentation](https://nbval.readthedocs.io/)
- [nbstripout documentation](https://github.com/kynan/nbstripout)
- [ruff documentation](https://docs.astral.sh/ruff/)
- [Jupyter best practices](https://jupyter.org/best-practices)
