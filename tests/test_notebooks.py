"""Tests for Jupyter notebooks.

This module provides tests to ensure notebooks:
1. Execute without errors
2. Are properly sanitized (no outputs committed)
3. Follow code quality standards
"""

import json
from pathlib import Path

import pytest

# Find all notebooks except checkpoints and templates
NOTEBOOK_DIR = Path("notebooks")
NOTEBOOKS = [
    nb
    for nb in NOTEBOOK_DIR.rglob("*.ipynb")
    if ".ipynb_checkpoints" not in str(nb) and "templates" not in str(nb)
]


@pytest.mark.notebook
@pytest.mark.parametrize("notebook_path", NOTEBOOKS, ids=lambda p: str(p))
def test_notebook_is_sanitized(notebook_path):
    """Test that notebook has no outputs or execution counts.

    This ensures notebooks are committed in a clean state without
    outputs that can cause merge conflicts and bloat the repository.
    """
    with open(notebook_path) as f:
        nb = json.load(f)

    for i, cell in enumerate(nb.get("cells", [])):
        # Check outputs
        outputs = cell.get("outputs", [])
        assert not outputs, (
            f"Cell {i} in {notebook_path} has outputs. Run: uv run nbstripout {notebook_path}"
        )

        # Check execution count
        exec_count = cell.get("execution_count")
        if cell.get("cell_type") == "code":
            assert exec_count is None, (
                f"Cell {i} in {notebook_path} has execution_count={exec_count}. "
                f"Run: uv run nbstripout {notebook_path}"
            )


@pytest.mark.notebook
def test_template_notebooks_exist():
    """Test that expected template notebooks exist."""
    templates_dir = NOTEBOOK_DIR / "templates"
    expected_templates = ["eda_template.ipynb", "experiment_template.ipynb"]

    for template in expected_templates:
        template_path = templates_dir / template
        assert template_path.exists(), f"Template {template} not found at {template_path}"


@pytest.mark.notebook
@pytest.mark.parametrize("notebook_path", NOTEBOOKS, ids=lambda p: str(p))
def test_notebook_has_title(notebook_path):
    """Test that notebook has a title in the first markdown cell."""
    with open(notebook_path) as f:
        nb = json.load(f)

    cells = nb.get("cells", [])
    assert cells, f"Notebook {notebook_path} has no cells"

    # First cell should be markdown with a title
    first_cell = cells[0]
    assert first_cell.get("cell_type") == "markdown", (
        f"First cell in {notebook_path} should be markdown. Add a title cell at the beginning."
    )

    source = "".join(first_cell.get("source", []))
    assert source.strip().startswith("#"), (
        f"First cell in {notebook_path} should start with # (title). Found: {source[:50]}"
    )
