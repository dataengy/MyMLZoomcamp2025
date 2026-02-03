# Project Skills & Agents

Custom skills and agents for ML Zoomcamp project development.

## Overview

This document proposes specialized skills/agents for common ML project tasks.

## Proposed Skills

### 1. Data Science & ML

#### `/eda` - Exploratory Data Analysis
**Purpose:** Automate EDA generation with visualizations and statistical summaries

**Triggers:**
- "Create EDA for dataset X"
- "Analyze data distribution"
- "Generate data quality report"

**Actions:**
- Load data from `data/processed/`
- Generate statistical summaries
- Create distribution plots
- Check for missing values, outliers
- Save report to `reports/eda_{dataset}_{date}.html`

#### `/experiment` - ML Experiment Runner
**Purpose:** Run and track ML experiments with different models and hyperparameters

**Triggers:**
- "Run experiment with RandomForest"
- "Compare LinearRegression vs GradientBoosting"
- "Tune hyperparameters for XGBoost"

**Actions:**
- Load data and split
- Train baseline model
- Train experiment model(s)
- Compare metrics
- Save results to `reports/experiments/`
- Update experiment tracking log

#### `/feature-engineer` - Feature Engineering Assistant
**Purpose:** Generate and test new features

**Triggers:**
- "Create polynomial features"
- "Test feature interactions"
- "Generate time-based features"

**Actions:**
- Analyze existing features
- Suggest new feature combinations
- Test feature importance
- Generate feature engineering code
- Save feature definitions

### 2. MLOps & DevOps

#### `/model-registry` - Model Registry Manager
**Purpose:** Version, tag, and manage trained models

**Triggers:**
- "Register model"
- "Promote model to production"
- "Compare model versions"

**Actions:**
- Version model with metadata
- Tag models (dev/staging/prod)
- Track model lineage
- Generate model cards
- Update model registry

#### `/data-validation` - Data Quality Validator
**Purpose:** Validate data quality and schema

**Triggers:**
- "Validate dataset schema"
- "Check data quality"
- "Generate data validation report"

**Actions:**
- Check schema compliance
- Validate data types and ranges
- Detect outliers and anomalies
- Generate validation report
- Fail pipeline if critical issues found

#### `/deploy` - Deployment Assistant
**Purpose:** Help with model deployment tasks

**Triggers:**
- "Deploy model to staging"
- "Create deployment package"
- "Update API with new model"

**Actions:**
- Package model with dependencies
- Update Docker image
- Generate deployment checklist
- Update API endpoints
- Run smoke tests

### 3. Data Engineering

#### `/pipeline-builder` - Data Pipeline Builder
**Purpose:** Create and modify Dagster data pipelines

**Triggers:**
- "Create pipeline for dataset X"
- "Add transformation step"
- "Schedule pipeline daily"

**Actions:**
- Generate Dagster asset definitions
- Create pipeline configuration
- Add data quality checks
- Set up scheduling
- Generate pipeline documentation

#### `/data-profiler` - Data Profiler
**Purpose:** Generate comprehensive data profiles

**Triggers:**
- "Profile dataset"
- "Generate data catalog entry"
- "Analyze data distribution"

**Actions:**
- Generate pandas-profiling report
- Create data catalog entry
- Document data lineage
- Save profile to `reports/profiles/`

### 4. Quality Assurance

#### `/test-coverage` - Test Coverage Analyzer
**Purpose:** Analyze and improve test coverage

**Triggers:**
- "Check test coverage"
- "Generate coverage report"
- "Identify untested code"

**Actions:**
- Run pytest with coverage
- Generate HTML coverage report
- Identify low-coverage modules
- Suggest test cases
- Update CI/CD configuration

#### `/integration-test` - Integration Test Generator
**Purpose:** Create integration tests for pipelines

**Triggers:**
- "Create integration tests"
- "Test end-to-end pipeline"
- "Validate API integration"

**Actions:**
- Generate test fixtures
- Create integration test suite
- Mock external dependencies
- Set up test database
- Generate test documentation

### 5. Documentation & Reporting

#### `/doc-generator` - Documentation Generator
**Purpose:** Auto-generate documentation from code

**Triggers:**
- "Generate API docs"
- "Update README"
- "Create pipeline documentation"

**Actions:**
- Extract docstrings
- Generate API reference
- Create usage examples
- Update README sections
- Generate diagrams

#### `/report-builder` - Report Builder
**Purpose:** Create ML experiment and model reports

**Triggers:**
- "Generate model report"
- "Create experiment summary"
- "Build performance dashboard"

**Actions:**
- Compile metrics from experiments
- Generate visualizations
- Create model cards
- Build HTML/PDF reports
- Update tracking spreadsheet

## Implementation Plan

### Phase 1: Core ML Skills
1. `/experiment` - Highest priority for iterative model development
2. `/eda` - Essential for data understanding
3. `/feature-engineer` - Accelerate feature development

### Phase 2: MLOps
1. `/model-registry` - Model versioning and tracking
2. `/data-validation` - Ensure data quality
3. `/deploy` - Streamline deployment

### Phase 3: Infrastructure
1. `/pipeline-builder` - Automate Dagster pipeline creation
2. `/test-coverage` - Maintain code quality
3. `/doc-generator` - Keep documentation current

## Skill Configuration

Skills would be stored in:
```
.ai/skills/
├── experiment/
│   ├── skill.yml
│   ├── prompt.md
│   └── templates/
├── eda/
│   ├── skill.yml
│   ├── prompt.md
│   └── templates/
└── ...
```

## Integration with Workflow

Skills integrate with existing workflow:
1. User invokes skill: `/experiment`
2. Skill reads project context
3. Executes specialized logic
4. Saves artifacts to appropriate directories
5. Updates documentation and logs

## See Also

- [Agent Notes](AGENTS.md) - Project conventions
- [TODO](TODO.md) - Implementation roadmap
- [Notebooks](../notebooks/README.md) - Manual experimentation
- [Documentation](../docs/README.md) - Full documentation
