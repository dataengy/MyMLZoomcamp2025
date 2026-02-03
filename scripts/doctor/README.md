# Doctor Scripts

Diagnostic and repair scripts for common project issues.

## Scripts

### run-tests-safe.py
Runs the test suite with safe defaults to avoid long runtimes and flaky log output.

**Features:**
- Sets conservative env defaults (sample size, output format, logging)
- Clears LOG_FORMAT/LOG_LEVEL to rely on config
- Accepts any command (defaults to `make test`)

**Usage:**
```bash
# Default: make test with safe env vars
./scripts/doctor/run-tests-safe.py

# Run a custom command with the same env safety
./scripts/doctor/run-tests-safe.py uv run pytest -q
```

**When to use:**
- Tests are timing out or running on large datasets
- Log output is inconsistent in pytest

### web-tool-check.sh
Checks that a local web tool (e.g., Dagster UI) responds.

**Features:**
- Verifies the URL responds with HTTP 2xx/3xx
- Detects the 0.0.0.0 bind address and suggests localhost
- Retries with configurable timeout and sleep

**Usage:**
```bash
# Default: check http://127.0.0.1:3000
./scripts/doctor/web-tool-check.sh

# Check a specific URL
./scripts/doctor/web-tool-check.sh --url http://127.0.0.1:3000
```

**When to use:**
- Dagster reports it is serving but the UI doesn't open
- You see logs like "Serving dagster-webserver on http://0.0.0.0:3000"

### loc-01-git-sync-push.sh
Handles git push failures due to diverged branches.

**Features:**
- Auto-detects when local branch is behind remote
- Offers rebase or merge to sync
- Handles uncommitted changes with auto-stash
- Supports dry-run mode
- Fixes common push rejection issues

**Usage:**
```bash
# Interactive mode
./scripts/doctor/loc-01-git-sync-push.sh

# Auto-mode with rebase
./scripts/doctor/loc-01-git-sync-push.sh --auto-stash --rebase

# Dry-run to see what would happen
./scripts/doctor/loc-01-git-sync-push.sh --dry-run

# Specific remote and branch
./scripts/doctor/loc-01-git-sync-push.sh origin main --rebase
```

**When to use:**
- Git push fails with "non-fast-forward" error
- Local branch diverged from remote
- Need to sync before pushing

### loc-02-project-health-check.sh
Comprehensive project health check.

**Features:**
- Verifies git repository status
- Checks uv.lock file (creation and tracking)
- Validates Python environment
- Ensures dependencies are synced
- Detects git branch sync issues
- Verifies required project files exist
- Auto-fix mode for common issues

**Usage:**
```bash
# Check only (no modifications)
./scripts/doctor/loc-02-project-health-check.sh

# Check and auto-fix issues
./scripts/doctor/loc-02-project-health-check.sh --fix

# Verbose output
./scripts/doctor/loc-02-project-health-check.sh --verbose
```

**When to use:**
- Before committing/pushing
- After cloning the repository
- When CI fails
- Regular project maintenance
- Troubleshooting environment issues

### github_push_doctor.sh
Legacy interactive git push troubleshooting tool.

**Features:**
- Tests GitHub SSH authentication
- Verifies remote connectivity
- Updates remote URLs
- Handles push failures interactively

**Usage:**
```bash
./scripts/doctor/github_push_doctor.sh [remote-name]
```

**Note:** Consider using `loc-01-git-sync-push.sh` instead for a more automated experience.

## Common Issues Solved

### 1. Git Push Rejected (non-fast-forward)
**Error:**
```
! [rejected] main -> main (non-fast-forward)
error: failed to push some refs
```

**Solution:**
```bash
./scripts/doctor/loc-01-git-sync-push.sh --auto-stash --rebase
```

### 2. Missing uv.lock in CI
**Error:**
```
error: Unable to find lockfile at `uv.lock`
```

**Solution:**
```bash
./scripts/doctor/loc-02-project-health-check.sh --fix
```

### 3. Virtual Environment Not Set Up
**Error:**
```
ModuleNotFoundError: No module named 'xyz'
```

**Solution:**
```bash
uv sync
# or
./scripts/doctor/loc-02-project-health-check.sh --fix
```

## Naming Convention

Scripts follow the project's naming convention:
- `loc-<nr>-<name>.sh` - Local scripts (run on local machine)
- `host-<nr>-<name>.sh` - Remote scripts (run on remote hosts)

## Integration with Make/Just

Add to your Makefile:
```makefile
.PHONY: doctor
doctor:
	@./scripts/doctor/loc-02-project-health-check.sh

.PHONY: doctor-fix
doctor-fix:
	@./scripts/doctor/loc-02-project-health-check.sh --fix

.PHONY: sync-push
sync-push:
	@./scripts/doctor/loc-01-git-sync-push.sh --auto-stash --rebase
```

Or Justfile:
```just
# Run project health check
doctor:
    ./scripts/doctor/loc-02-project-health-check.sh

# Run health check and auto-fix issues
doctor-fix:
    ./scripts/doctor/loc-02-project-health-check.sh --fix

# Sync with remote and push
sync-push:
    ./scripts/doctor/loc-01-git-sync-push.sh --auto-stash --rebase

# Run tests with safe env defaults
test-safe:
    ./scripts/doctor/run-tests-safe.py
```

## Contributing

When adding new doctor scripts:
1. Follow the naming convention (`loc-<nr>-<name>.sh`)
2. Use the utilities from `scripts/utils/utils.sh`
3. Support `--help` flag
4. Include error handling with `set -euo pipefail`
5. Document in this README
