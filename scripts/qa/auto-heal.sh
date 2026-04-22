#!/usr/bin/env bash
set -euo pipefail

log_dir=".guardrail"
mkdir -p "$log_dir"
log_file="$log_dir/last-run.log"

./scripts/qa/sync-compose-runtime.sh

run_verify() {
  ./scripts/qa/verify-gates.sh quick 2>&1 | tee "$log_file"
}

is_frontend_container_running() {
  command -v docker >/dev/null 2>&1 \
    && docker compose ps --status running frontend 2>/dev/null | grep -q "frontend"
}

auto_fix() {
  local applied=0

  if grep -Eq "Cannot find package '@shared/error-message'|Failed to resolve import .*error-message" "$log_file"; then
    echo "[auto-heal] detected shared import resolution issue -> clearing Vite caches"
    rm -rf apps/frontend/node_modules/.vite apps/line-choi/node_modules/.vite

    if is_frontend_container_running; then
      echo "[auto-heal] frontend container is running -> recreating service to refresh volume mounts"
      docker compose up -d --force-recreate frontend
    fi

    applied=1
  fi

  if grep -q "outside of Vite serving allow list" "$log_file"; then
    echo "[auto-heal] detected Vite fs.allow issue signature"
    echo "[auto-heal] no safe runtime-only patch is possible; configuration changes are required"
  fi

  if grep -Eq "ERR_MODULE_NOT_FOUND|Cannot find module" "$log_file"; then
    echo "[auto-heal] detected module resolution instability -> reinstalling workspace deps"
    npm install
    applied=1
  fi

  if [[ "$applied" -eq 1 ]]; then
    return 0
  fi
  return 1
}

echo "[auto-heal] initial verification"
if run_verify; then
  echo "[auto-heal] no action needed"
  exit 0
fi

echo "[auto-heal] verification failed; attempting automated fixes"
if auto_fix; then
  echo "[auto-heal] automatic fixes applied"
else
  echo "[auto-heal] no automatic fix candidates were applicable"
  exit 1
fi

echo "[auto-heal] re-running verification after fixes"
run_verify

echo "[auto-heal] recovered successfully"
