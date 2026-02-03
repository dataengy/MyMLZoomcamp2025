---
name: pipeline-builder
description: Build or modify data pipelines (Dagster or project pipeline framework). Use when asked to create pipelines, add transformation steps, or schedule runs.
---

# Pipeline Builder

## Workflow

- Detect the pipeline framework in use (Dagster, custom, or other) and ask if unclear.
- Identify inputs, transformations, outputs, and schedules.
- Implement or update assets/jobs and config in `src/` or `deploy/`.
- Add data quality checks and logging.
- Document the pipeline and usage in `docs/`.

## Output

- Code changes plus a short usage note.
