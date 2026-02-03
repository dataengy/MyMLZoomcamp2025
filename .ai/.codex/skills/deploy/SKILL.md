---
name: deploy
description: Assist with model deployment tasks. Use when asked to deploy a model, create a deployment package, update an API, or run smoke tests.
---

# Deployment Assistant

## Workflow

- Identify the target environment (staging/prod) and model version.
- Package the model with dependencies; prefer existing scripts in `deploy/` or `scripts/`.
- Update Docker or service config as needed.
- Generate a deployment checklist and run smoke tests if available.
- Summarize changes and any required follow-ups.

## Output

- Deployment steps taken and results of smoke tests.
