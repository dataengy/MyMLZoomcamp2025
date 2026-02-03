# Codex Scripts

Utilities for Codex CLI workflows (installing local skills).

## Files

- `Justfile` - just wrappers for common tasks
- `install_local_skills.sh` - install skills from `.ai/.codex/skills/`

## Usage

Justfile wrappers:
```bash
# Show available commands
just -f scripts/codex/Justfile help

# Install skills into $CODEX_HOME/skills (or ~/.codex/skills)
just -f scripts/codex/Justfile install-skills

# Overwrite existing skills
just -f scripts/codex/Justfile install-skills --force
```

Direct script usage:
```bash
scripts/codex/install_local_skills.sh
scripts/codex/install_local_skills.sh --force
```

Notes:
- Skills are sourced from `.ai/.codex/skills/`.
- Destination defaults to `~/.codex/skills` unless `CODEX_HOME` is set.
