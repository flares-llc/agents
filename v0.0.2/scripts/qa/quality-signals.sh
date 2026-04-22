#!/usr/bin/env bash
set -euo pipefail

BASELINE_FILE="${BASELINE_FILE:-scripts/qa/quality-signals-baseline.json}"
FLAKY_RUNS="${FLAKY_RUNS:-3}"
LOG_DIR="${LOG_DIR:-test-results}"
E2E_COVERAGE_COMMAND="${E2E_COVERAGE_COMMAND:-npm run test:all:e2e:coverage:stable}"
FLAKY_TEST_COMMAND="${FLAKY_TEST_COMMAND:-npm run test:web:e2e:stable}"

mkdir -p "$LOG_DIR"
UNIT_LOG="$LOG_DIR/quality-unit.log"
E2E_LOG="$LOG_DIR/quality-e2e.log"
OUT_JSON="$LOG_DIR/quality-signals.json"

if [[ ! -f "$BASELINE_FILE" ]]; then
  echo "[quality] baseline file not found: $BASELINE_FILE" >&2
  exit 2
fi

count_warnings() {
  local file="$1"
  (grep -Eio "warning|warn" "$file" || true) | wc -l | tr -d ' '
}

count_skips() {
  local file="$1"
  (grep -Eio "\bskipp?ed\b|\bskip\b" "$file" || true) | wc -l | tr -d ' '
}

read_baseline() {
  local section="$1"
  local key="$2"
  node -e "const fs=require('fs'); const b=JSON.parse(fs.readFileSync(process.argv[1],'utf8')); console.log(b[process.argv[2]][process.argv[3]]);" "$BASELINE_FILE" "$section" "$key"
}

check_growth() {
  local stage="$1"
  local warnings="$2"
  local skips="$3"
  local base_warnings base_skips

  base_warnings="$(read_baseline "$stage" warnings)"
  base_skips="$(read_baseline "$stage" skips)"

  echo "[quality] $stage warnings=$warnings (baseline=$base_warnings), skips=$skips (baseline=$base_skips)"

  if (( warnings > base_warnings )); then
    echo "[quality] $stage warning count increased" >&2
    return 1
  fi

  if (( skips > base_skips )); then
    echo "[quality] $stage skip count increased" >&2
    return 1
  fi

  return 0
}

echo "[quality] running unit coverage"
npm run test:all:unit:coverage | tee "$UNIT_LOG"

UNIT_WARNINGS="$(count_warnings "$UNIT_LOG")"
UNIT_SKIPS="$(count_skips "$UNIT_LOG")"
check_growth "unit" "$UNIT_WARNINGS" "$UNIT_SKIPS"

echo "[quality] running e2e coverage"
bash -lc "$E2E_COVERAGE_COMMAND" | tee "$E2E_LOG"

E2E_WARNINGS="$(count_warnings "$E2E_LOG")"
E2E_SKIPS="$(count_skips "$E2E_LOG")"
check_growth "e2e" "$E2E_WARNINGS" "$E2E_SKIPS"

echo "[quality] running flaky check ($FLAKY_RUNS runs)"
FLAKY_TEST_COMMAND="$FLAKY_TEST_COMMAND" ./scripts/qa/flaky-check.sh "$FLAKY_RUNS"

node -e "const fs=require('fs'); const out={generatedAt:new Date().toISOString(), unit:{warnings:Number(process.argv[1]), skips:Number(process.argv[2])}, e2e:{warnings:Number(process.argv[3]), skips:Number(process.argv[4])}, flakyRuns:Number(process.argv[5])}; fs.writeFileSync(process.argv[6], JSON.stringify(out,null,2));" "$UNIT_WARNINGS" "$UNIT_SKIPS" "$E2E_WARNINGS" "$E2E_SKIPS" "$FLAKY_RUNS" "$OUT_JSON"

echo "[quality] signals written to $OUT_JSON"
echo "[quality] all checks passed"
