#!/usr/bin/env bash
set -euo pipefail

state_dir=".guardrail"
state_file="$state_dir/docker-compose.sha256"
compose_file="docker-compose.yml"

mkdir -p "$state_dir"

if [[ ! -f "$compose_file" ]]; then
  echo "[compose-sync] skip: $compose_file not found"
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "[compose-sync] skip: docker not installed"
  exit 0
fi

current_hash="$(shasum -a 256 "$compose_file" | awk '{print $1}')"
previous_hash=""

if [[ -f "$state_file" ]]; then
  previous_hash="$(cat "$state_file")"
fi

if [[ "$current_hash" == "$previous_hash" ]]; then
  echo "[compose-sync] compose hash unchanged"
  exit 0
fi

echo "[compose-sync] compose hash changed -> syncing runtime containers"

if docker compose ps --status running frontend 2>/dev/null | grep -q "frontend"; then
  echo "[compose-sync] recreating frontend container"
  docker compose up -d --force-recreate frontend
fi

if docker compose ps --status running line-choi 2>/dev/null | grep -q "line-choi"; then
  echo "[compose-sync] recreating line-choi container"
  docker compose up -d --force-recreate line-choi
fi

echo "$current_hash" > "$state_file"
echo "[compose-sync] sync complete"
