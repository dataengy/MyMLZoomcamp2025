---
name: data-validation
description: Validate dataset schema and data quality. Use when asked to check schema compliance, data quality, or generate validation reports.
---

# Data Validation

## Workflow

- Load the dataset and infer expected schema from prior runs or user input.
- Validate types, null rates, ranges, and category cardinality.
- Flag anomalies and outliers; distinguish warnings vs errors.
- Save a report to `reports/validation/validation_{dataset}_{YYYY-MM-DD}.html`.
- If requested for pipelines, fail the run on critical errors.

## Output

- Validation report plus a brief summary of blockers.
