# Setup Scripts

Utilities for bootstrapping the repo and managing environment configuration.

## Contents

- `setup.sh` - install tooling and sync dependencies.
- `env-check.py` - verify `config/.env` is synced with `config/.env.demo`.
- `env-render.py` / `env-render.sh` - render one or more env files from the demo.
- `env-render.env` - config for env-render defaults (demo + env file list).
- `docker-check.sh` - verify Docker environment is ready.
- `Justfile` - shortcuts for the commands in this folder.

## env-render configuration

`env-render.py` reads `scripts/setup/env-render.env` for defaults:

```
DEMO_FILE=config/.env.demo
ENV_FILES=config/.env
```

Set `ENV_FILES` to a comma-separated list to render multiple files (for example, `config/.env,config/.env.local`).

## Common commands

```bash
# Run setup
./scripts/setup/setup.sh

# Check env sync
python scripts/setup/env-check.py

# Render env files (non-interactive)
python scripts/setup/env-render.py

# Render env files (interactive)
python scripts/setup/env-render.py --interactive

# Using Just
just -f scripts/setup/Justfile env-check
```
