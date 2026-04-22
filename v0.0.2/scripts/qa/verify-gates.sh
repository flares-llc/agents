#!/usr/bin/env bash
set -euo pipefail

mode="${1:-quick}"

./scripts/qa/sync-compose-runtime.sh

is_frontend_container_running() {
  command -v docker >/dev/null 2>&1 \
    && docker compose ps --status running frontend 2>/dev/null | grep -q "frontend"
}

check_frontend_container_mount_and_import() {
  echo "[guard] docker frontend detected -> verifying shared mount and import serving"
  docker compose exec -T frontend sh -lc 'test -f /shared/src/error-message.ts'

  local status
  status="$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/app/lib/api.ts)"
  if [[ "$status" != "200" ]]; then
    echo "[guard] frontend module serving check failed: status=$status" >&2
    return 1
  fi
}

if [[ "$mode" != "quick" && "$mode" != "full" ]]; then
  echo "[guard] invalid mode: $mode (expected quick|full)" >&2
  exit 2
fi

echo "[guard] mode=$mode"
echo "[guard] 1/7 frontend typecheck"
npm --prefix apps/frontend run typecheck

if is_frontend_container_running; then
  check_frontend_container_mount_and_import
fi

echo "[guard] 2/7 line-choi build"
npm --prefix apps/line-choi run build

echo "[guard] 3/7 frontend unit"
npm run test:frontend:unit

echo "[guard] 4/7 line unit"
npm run test:line:unit

echo "[guard] 5/7 backend unit"
npm run test:backend:unit

echo "[guard] 6/7 security audit (high+)"
npm audit --omit=dev --audit-level=high

if [[ "$mode" == "full" ]]; then
  echo "[guard] 7/7 quality signals (coverage + flaky + warning/skip growth)"
  npm run qa:quality-signals
else
  echo "[guard] 7/7 skipped full e2e (quick mode)"
fi

echo "[guard] all gates passed"
