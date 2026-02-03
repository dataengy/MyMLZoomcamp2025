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
  "status": "ok",
  "timestamp": "2026-02-03T12:00:00Z"
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
  "prediction": 42.0,
  "model_version": "1.0.0",
  "timestamp": "2026-02-03T12:00:00Z"
}
```

**Error Response:**
```json
{
  "detail": "Model not loaded"
}
```

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
# Start with auto-reload
uvicorn src.api.main:app --reload --host 0.0.0.0 --port 8000
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

See [deployment.md](deployment.md#monitoring) for monitoring and observability setup.

## See Also

- [Model Development](model_development.md) - How models are trained and versioned
- [Deployment](deployment.md) - Production deployment guide
- [Architecture](architecture.md) - System design overview
