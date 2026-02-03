---
name: eda
description: Automate exploratory data analysis for project datasets. Use when asked to create EDA, analyze data distributions, or generate data quality reports for data in data/processed.
---

# EDA

## Workflow

- Confirm the dataset name and location; default to `data/processed/`.
- Load data with pandas, infer types, and capture row/column counts.
- Generate summary stats and missing-value tables.
- Create distribution plots for numeric columns and bar charts for categorical columns.
- Surface obvious outliers with simple IQR or z-score checks.
- Save a self-contained HTML report to `reports/eda_{dataset}_{YYYY-MM-DD}.html`.
- Note any data quality risks and recommended next steps.

## Output

- One HTML report plus a short written summary of key findings.
