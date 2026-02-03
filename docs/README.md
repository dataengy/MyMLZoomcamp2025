# Project Documentation

Detailed documentation for the ML Zoomcamp project.

## Contents

- [**Architecture**](architecture.md) - System design, components, and data flow
- [**API Reference**](api.md) - FastAPI endpoints and usage
- [**Data Pipeline**](data_pipeline.md) - Data ingestion, processing, and validation
- [**Model Development**](model_development.md) - Training, evaluation, and deployment
- [**Orchestration**](orchestration.md) - Dagster assets and schedules
- [**Deployment**](deployment.md) - Docker, environment setup, and production deployment
- [**Development Guide**](development.md) - Local setup, testing, and contribution guidelines
- [**Setup Scripts**](../scripts/setup/README.md) - Setup utilities and env sync helpers
- [**Dagster Assets**](../src/dags/README.md) - Asset definitions and required env vars

## Quick Links

### For Data Scientists
- [Getting Started with Notebooks](../notebooks/README.md)
- [Model Development Guide](model_development.md)
- [Data Pipeline Documentation](data_pipeline.md)

### For Developers
- [Development Guide](development.md)
- [API Reference](api.md)
- [Testing Guide](development.md#testing)

### For DevOps/MLOps
- [Deployment Guide](deployment.md)
- [Orchestration](orchestration.md)
- [Architecture](architecture.md)

## Project Structure

See the main [README](../README.md#structure) for an overview of the project structure.

## Additional Resources

- [`.ai/AGENTS.md`](../.ai/AGENTS.md) - AI agent notes and conventions
- [`.ai/TODO.md`](../.ai/TODO.md) - Project tasks and roadmap
- [`Makefile`](../Makefile) - Common development commands
- [`Justfile`](../Justfile) - Complex operations and pipelines
- [`scripts/setup/Justfile`](../scripts/setup/Justfile) - Setup command shortcuts
