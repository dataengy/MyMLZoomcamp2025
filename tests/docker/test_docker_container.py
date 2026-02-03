from __future__ import annotations

import os
import shutil
import subprocess
import time
from urllib.error import URLError
from urllib.request import Request, urlopen

import pytest


def _run_compose(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, check=True, capture_output=True, text=True)


def _wait_for_health(url: str, timeout_seconds: int = 30) -> bool:
    deadline = time.time() + timeout_seconds
    while time.time() < deadline:
        try:
            with urlopen(url, timeout=2) as response:
                if response.status == 200:
                    return True
        except URLError:
            time.sleep(1)
    return False


@pytest.mark.integration
@pytest.mark.skipif(
    os.environ.get("DOCKER_TESTS") != "1" or shutil.which("docker") is None,
    reason="Docker tests disabled (set DOCKER_TESTS=1) or docker not available.",
)
def test_docker_container_health() -> None:
    compose_args = [
        "docker",
        "compose",
        "-f",
        "deploy/docker-compose.yml",
        "up",
        "-d",
        "--build",
        "api",
    ]
    down_args = [
        "docker",
        "compose",
        "-f",
        "deploy/docker-compose.yml",
        "down",
        "--remove-orphans",
    ]

    try:
        try:
            _run_compose(compose_args)
        except subprocess.CalledProcessError as exc:
            stderr = (exc.stderr or "").lower()
            transient_markers = [
                "cannot connect to the docker daemon",
                "unexpected end of json input",
                "connection refused",
                "context deadline exceeded",
            ]
            if any(marker in stderr for marker in transient_markers):
                pytest.skip(f"Docker compose failed (transient): {exc.stderr.strip()}")
            raise
        assert _wait_for_health("http://localhost:8000/health")
    finally:
        subprocess.run(down_args, check=False)


@pytest.mark.integration
@pytest.mark.skipif(
    os.environ.get("DOCKER_TESTS") != "1" or shutil.which("docker") is None,
    reason="Docker tests disabled (set DOCKER_TESTS=1) or docker not available.",
)
def test_docker_container_predict() -> None:
    compose_args = [
        "docker",
        "compose",
        "-f",
        "deploy/docker-compose.yml",
        "up",
        "-d",
        "--build",
        "api",
    ]
    down_args = [
        "docker",
        "compose",
        "-f",
        "deploy/docker-compose.yml",
        "down",
        "--remove-orphans",
    ]
    create_model_cmd = [
        "docker",
        "compose",
        "-f",
        "deploy/docker-compose.yml",
        "exec",
        "-T",
        "api",
        "uv",
        "run",
        "python",
        "-",
    ]

    try:
        try:
            _run_compose(compose_args)
        except subprocess.CalledProcessError as exc:
            stderr = (exc.stderr or "").lower()
            transient_markers = [
                "cannot connect to the docker daemon",
                "unexpected end of json input",
                "connection refused",
                "context deadline exceeded",
            ]
            if any(marker in stderr for marker in transient_markers):
                pytest.skip(f"Docker compose failed (transient): {exc.stderr.strip()}")
            raise

        assert _wait_for_health("http://localhost:8000/health")

        model_script = """
from pathlib import Path
import joblib
from sklearn.dummy import DummyRegressor

model_path = Path("/app/models/model.joblib")
model_path.parent.mkdir(parents=True, exist_ok=True)

features = ["trip_distance", "passenger_count"]
model = DummyRegressor(strategy="mean")
model.fit([[1.0, 1.0], [2.0, 2.0]], [300.0, 600.0])

joblib.dump(
    {
        "model": model,
        "features": features,
        "target": "trip_duration",
        "model_type": "dummy",
        "params": {},
    },
    model_path,
)
print(model_path)
"""
        subprocess.run(
            create_model_cmd,
            input=model_script,
            text=True,
            check=True,
            capture_output=True,
        )

        request = Request(
            "http://localhost:8000/predict",
            data=b'{"features":{"trip_distance":2.0,"passenger_count":3.0}}',
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urlopen(request, timeout=5) as response:
            assert response.status == 200
            body = response.read().decode("utf-8")
            assert "prediction" in body
    finally:
        subprocess.run(down_args, check=False)
