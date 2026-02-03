---
name: experiment
description: Run and compare ML experiments with different models or hyperparameters. Use when asked to run experiments, compare models, or tune hyperparameters.
---

# Experiment Runner

## Workflow

- Identify dataset, target column, and metric; ask if any are missing.
- Load data, split into train/validation/test with a fixed seed.
- Train a baseline model and report baseline metrics.
- Train the requested model(s) and compare against baseline.
- Save artifacts (metrics table, config, and model paths) to `reports/experiments/`.
- Append a concise entry to `reports/experiments/EXPERIMENT_LOG.md`.

## Output

- Metrics table and a short comparison summary.
