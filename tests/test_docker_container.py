from __future__ import annotations

import os
import shutil
import subprocess
import time
from urllib.error import URLError
from urllib.request import urlopen

import pytest


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


@pytest.mark.skipif(
    os.environ.get("DOCKER_TESTS") != "1" or shutil.which("docker") is None,
    reason="Docker tests disabled (set DOCKER_TESTS=1) or docker not available.",
)
def test_docker_container_health() -> None:
    compose_args = ["docker", "compose", "up", "-d", "--build"]
    down_args = ["docker", "compose", "down", "--remove-orphans"]

    try:
        subprocess.run(compose_args, check=True)
        assert _wait_for_health("http://localhost:8000/health")
    finally:
        subprocess.run(down_args, check=False)
