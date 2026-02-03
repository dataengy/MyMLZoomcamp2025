# Notebook Testing - Quick Reference

## Quick Commands

```bash
# Lint notebooks
just nb-lint

# Format notebooks
just nb-fmt

# Check sanitized (no outputs)
just nb-check

# Strip outputs
just nb-strip

# Test execution
just nb-test

# Enable verbose logging
TRACE=1 just nb-check
```

## Pre-commit Hooks

Automatically runs on `git commit`:
- ✓ Lint with ruff
- ✓ Format with ruff
- ✓ Strip outputs

Enable:
```bash
pre-commit install
```

## Before Committing

```bash
just nb-strip     # Strip outputs
just nb-fmt       # Format code
just nb-check     # Lint + verify
git add notebooks/
git commit -m "Update analysis"
```

## Tools Installed

| Tool | Purpose |
|------|---------|
| nbqa | Run ruff on notebooks |
| nbstripout | Strip outputs |
| nbval | Test execution |
| pytest | Test structure |

## Files Added

```
.nbstripout                          # nbstripout config
.gitlab-ci.yml                       # GitLab CI config
scripts/notebooks/
  ├── lint_notebooks.sh              # Lint with ruff
  ├── format_notebooks.sh            # Format with ruff
  ├── check_sanitized.sh             # Verify no outputs
  ├── strip_notebooks.sh             # Strip all outputs
  └── test_notebooks.sh              # Test execution
scripts/setup/
  └── docker-check.sh                # Docker validation
tests/test_notebooks.py              # Pytest tests
docs/notebook-testing.md             # Full documentation
```

## Configuration Files Updated

- `pyproject.toml` - Added nbqa, nbval, nbstripout, pytest config
- `.pre-commit-config.yaml` - Added notebook hooks
- `Justfile` - Added notebook recipes with TRACE logging
- `.github/workflows/ci.yml` - Added notebook CI jobs
- `README.md` - Added notebook section

## Troubleshooting

**Hook fails:** `uv sync` then `pre-commit run --all-files`

**Outputs not stripped:** `just nb-strip`

**CI fails:** Check notebooks are sanitized locally first

**Execution timeout:** Mark notebooks as slow or skip in CI

## Full Documentation

See [`docs/notebook-testing.md`](notebook-testing.md) for complete guide.
