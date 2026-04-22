#!/usr/bin/env bash
set -euo pipefail

runs="${1:-3}"
test_command="${FLAKY_TEST_COMMAND:-npm run test:web:e2e}"

if ! [[ "$runs" =~ ^[0-9]+$ ]] || [[ "$runs" -lt 1 ]]; then
  echo "[flaky-check] invalid runs: $runs (expected positive integer)" >&2
  exit 2
fi

echo "[flaky-check] running web e2e $runs time(s)"
echo "[flaky-check] command: $test_command"

for i in $(seq 1 "$runs"); do
  echo "[flaky-check] round $i/$runs"
  bash -lc "$test_command"
done

echo "[flaky-check] completed without failures"
