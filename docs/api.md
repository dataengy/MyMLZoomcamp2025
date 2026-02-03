# API Reference

FastAPI service documentation.

## Base URL

- **Local**: `http://localhost:8000`
- **Docker**: `http://localhost:8000`

## Endpoints

### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "ok"
}
```

### Prediction

```http
POST /predict
```

**Request Body:**
```json
{
  "features": [1.0, 2.0, 3.0, 4.0]
}
```

**Response:**
```json
{
  "prediction": 7.0
}
```

> Note: the placeholder `/predict` sums `features`; once a real model is wired in the response shape stays the same but values will change.

## Running the API

### Local

```bash
make serve
```

### Docker

```bash
./docker-start.sh api
# or
docker compose -f deploy/docker-compose.yml up api
```

### Interactive Development

```bash
# Start with auto-reload (PYTHONPATH=src exposes the src/ packages)
PYTHONPATH=src uv run uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

## API Documentation

When the service is running, visit:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **OpenAPI JSON**: `http://localhost:8000/openapi.json`

## Authentication

Currently, the API does not require authentication. For production deployment, consider adding:
- API keys
- JWT tokens
- OAuth2

## Rate Limiting

Not currently implemented. For production, consider adding rate limiting to prevent abuse.

## Monitoring

TODO: Add monitoring and observability setup documentation.

## See Also

- [Model Development](model_development.md) - How models are trained and versioned
- [Data Pipeline](data_pipeline.md) - Data ingestion and processing
- [Development](development.md) - Local development and Docker setup
