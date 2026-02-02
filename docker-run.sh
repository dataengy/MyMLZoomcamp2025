#!/usr/bin/env sh
set -eu

docker compose build --no-cache api
docker compose up
