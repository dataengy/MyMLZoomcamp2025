---
name: model-registry
description: Manage model versions, tags, and metadata. Use when asked to register, compare, or promote model versions.
---

# Model Registry

## Workflow

- Identify the model artifact path and training data snapshot.
- Create or update a registry entry under `models/registry/`.
- Record metadata: training date, dataset version, features, metrics, and commit hash.
- Apply tags (dev/staging/prod) as requested.
- Generate or update a model card in `reports/model-cards/`.

## Output

- Registry entry and a short summary of version and tags.
