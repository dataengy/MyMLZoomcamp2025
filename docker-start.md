# Docker Start Guide

This guide documents the helper scripts for running Docker services in this repo.
It covers `docker-start.sh` (primary CLI) and `docker-start.just` (Just wrappers).

## Overview

- `docker-start.sh` is the primary entry point. It supports CLI mode and an interactive menu.
- `deploy/docker-compose.yml` is the compose file used by all helpers.
- `docker-start.just` provides convenient Just recipes that call `docker-start.sh` or `docker compose` directly.

## Quick Start

Start a service (foreground):

```bash
./docker-start.sh api
```

Start a service (background):

```bash
./docker-start.sh -d streamlit
```

Start an interactive shell in a service:

```bash
./docker-start.sh -i api
```

Run a command inside a service:

```bash
./docker-start.sh -i -c "bash" api
```

Open the interactive menu:

```bash
./docker-start.sh --menu
```

## CLI Options

```text
Usage: ./docker-start.sh [options] [service]

Options:
  -b, --build           Build before starting (default)
  --no-build            Skip build
  -n, --no-cache        Build with --no-cache
  -d, --detach          Run in background
  -i, --interactive     Attach to a service with exec
  -m, --menu            Interactive menu mode
  -c, --command CMD     Command to run (with --interactive)
  -h, --help            Show this help

Services:
  api                   FastAPI service
  dagster               Dagster orchestration
  streamlit             Streamlit UI
  jupyter               Jupyter Lab
```

## Interactive Menu

The menu provides options to:
- Start services (foreground/background)
- Open interactive shells in containers
- Build services (with/without cache)
- Stop all services
- View logs

Launch the menu:

```bash
./docker-start.sh --menu
```

## Just Recipes (docker-start.just)

Use these when you prefer `just` recipes for common flows.

Show help:

```bash
just -f docker-start.just help
```

Start a service (foreground):

```bash
just -f docker-start.just start service=api
```

Start a service (background):

```bash
just -f docker-start.just start-bg service=streamlit
```

Interactive shell in a service:

```bash
just -f docker-start.just interactive service=api
```

Run a command in a service:

```bash
just -f docker-start.just interactive service=api command='bash'
```

Tail logs (all or a specific service):

```bash
just -f docker-start.just logs
just -f docker-start.just logs service=dagster
```

Build images (all or a specific service):

```bash
just -f docker-start.just build
just -f docker-start.just build service=jupyter
```

Build images without cache:

```bash
just -f docker-start.just build-nocache
```

Bring all services down:

```bash
just -f docker-start.just down
```

## Troubleshooting

- If Docker or Compose is missing, `docker-start.sh` will error out during dependency checks.
- Make sure `deploy/docker-compose.yml` exists and is readable.
- For environment setup, run `just docker-check` or `./scripts/setup/docker-check.sh` as needed.
