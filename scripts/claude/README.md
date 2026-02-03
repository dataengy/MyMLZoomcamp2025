# Claude Scripts

Utilities for Claude Code workflows (context snapshots and skill installation).

## Files

- `Justfile` - just wrappers for common tasks
- `context.sh` - snapshot of git status, TODOs, and recent prompts
- `install_skills.sh` - build and install skills from `.ai/skills/` to `.claude/skills/`

## Usage

Justfile wrappers:
```bash
# Show available commands
just -f scripts/claude/Justfile help

# Context snapshot (default is last 5 prompts)
just -f scripts/claude/Justfile context
just -f scripts/claude/Justfile context 10

# Install skills (project-local by default)
just -f scripts/claude/Justfile install-skills

# Install globally
just -f scripts/claude/Justfile install-skills --global

# Install a single skill
just -f scripts/claude/Justfile install-skills --only experiment --force

# Dry-run or list skills
just -f scripts/claude/Justfile install-skills --dry-run
just -f scripts/claude/Justfile install-skills --list
```

Direct script usage:
```bash
scripts/claude/context.sh --prompts 10
scripts/claude/install_skills.sh --list
```

Notes:
- `install_skills.sh` assembles `SKILL.md` from `skill.yml` + `prompt.md` on install.
- Use `--local` (default) for `.claude/skills/` or `--global` for `~/.claude/skills/`.
