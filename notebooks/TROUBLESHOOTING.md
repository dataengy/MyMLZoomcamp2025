# Notebook Troubleshooting

Common issues and solutions when working with Jupyter notebooks.

## ModuleNotFoundError

### Problem
```python
ModuleNotFoundError: No module named 'seaborn'
```

### Solutions

**1. Ensure dependencies are synced (Local):**
```bash
uv sync
```

**2. Restart Jupyter kernel:**
- In Jupyter Lab: `Kernel` → `Restart Kernel`
- Or restart the Jupyter server:
  ```bash
  # Stop current server (Ctrl+C)
  make jupyter
  ```

**3. Docker: Rebuild image:**
```bash
docker compose -f deploy/docker-compose.yml down
docker compose -f deploy/docker-compose.yml build jupyter
docker compose -f deploy/docker-compose.yml up jupyter
# or
./docker-start.sh --no-cache jupyter
```

**4. Verify package installation:**
```bash
# Local
uv run python -c "import seaborn; print(seaborn.__version__)"

# Docker
docker compose -f deploy/docker-compose.yml exec jupyter python -c "import seaborn; print(seaborn.__version__)"
```

## Installed Packages

The project includes these data science packages:

- **numpy** - Numerical computing
- **pandas** - Data manipulation
- **matplotlib** - Plotting
- **seaborn** - Statistical visualization
- **scikit-learn** - Machine learning
- **joblib** - Model serialization
- **jupyterlab** - Interactive notebooks

## Adding New Packages

### Local Development

```bash
# Add package
uv add package-name

# Sync environment
uv sync
```

### Docker

After adding to `pyproject.toml`:
```bash
# Rebuild image
./docker-start.sh --no-cache jupyter
```

## Kernel Issues

### Kernel Dies or Restarts

**Possible causes:**
- Out of memory
- Infinite loops
- Large dataset operations

**Solutions:**
1. Reduce dataset size:
   ```python
   df = df.sample(n=10000, random_state=42)
   ```

2. Use chunking for large files:
   ```python
   chunks = pd.read_csv('large.csv', chunksize=10000)
   for chunk in chunks:
       process(chunk)
   ```

3. Clear outputs and restart:
   ```bash
   # In notebook
   Kernel → Restart Kernel and Clear All Outputs
   ```

### Wrong Kernel Selected

**Ensure you're using the project environment:**

In Jupyter Lab:
1. Click kernel name (top right)
2. Select Python 3 kernel from project's `.venv`

## Import Errors

### Relative Imports

```python
# ❌ Don't do this in notebooks
from ..src.training import model

# ✅ Do this instead
import sys
from pathlib import Path
sys.path.insert(0, str(Path.cwd().parent))

from src.training import model
```

### Path Issues

```python
# Always use absolute paths from project root
from pathlib import Path

PROJECT_ROOT = Path.cwd().parent  # if in notebooks/
DATA_DIR = PROJECT_ROOT / "data"
MODELS_DIR = PROJECT_ROOT / "models"

df = pd.read_parquet(DATA_DIR / "processed" / "data.parquet")
```

## Matplotlib Not Displaying

```python
# Ensure inline plotting is enabled
%matplotlib inline

import matplotlib.pyplot as plt
```

## Jupyter Not Starting

### Port Already in Use

```bash
# Find process using port 8888
lsof -ti:8888 | xargs kill -9

# Or use different port
jupyter lab --port 8889
```

### Token/Password Issues

Set token in [`config/.env`](../config/.env):
```bash
JUPYTER_TOKEN=your-secure-token
# or empty for no auth (dev only)
JUPYTER_TOKEN=
```

## Performance Issues

### Large Datasets

```python
# Use duckdb for large datasets
import duckdb

conn = duckdb.connect()
result = conn.execute("""
    SELECT * FROM 'data/large_file.parquet'
    WHERE condition = true
    LIMIT 10000
""").df()
```

### Memory Usage

```python
# Check memory usage
import pandas as pd

df.info(memory_usage='deep')

# Optimize dtypes
df['category_col'] = df['category_col'].astype('category')
df['int_col'] = pd.to_numeric(df['int_col'], downcast='integer')
```

## Getting Help

1. Check [notebooks/README.md](README.md) for best practices
2. Review [docs/development.md](../docs/development.md) for environment setup
3. See [.ai/AGENTS.md](../.ai/AGENTS.md) for project conventions
4. Check Jupyter logs:
   ```bash
   # Local
   Check terminal where jupyter is running

   # Docker
   docker compose -f deploy/docker-compose.yml logs jupyter
   ```
