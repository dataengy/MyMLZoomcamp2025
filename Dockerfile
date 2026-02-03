FROM python:3.13-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_SYSTEM_PYTHON=1 \
    DAGSTER_HOME=/app/.dagster \
    PYTHONPATH=/app/src \
    PATH="/app/.venv/bin:${PATH}"

RUN mkdir -p /app/.dagster

RUN pip install --no-cache-dir uv

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

COPY config ./config
COPY src ./src
COPY .streamlit ./.streamlit
COPY notebooks ./notebooks

EXPOSE 8000 3000 8501 8888

CMD ["uv", "run", "uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000", "--app-dir", "/app/src"]
