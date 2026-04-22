#!/usr/bin/env bash
set -euo pipefail

chmod +x .githooks/pre-commit .githooks/pre-push .githooks/post-merge .githooks/post-checkout \
	scripts/qa/verify-gates.sh scripts/qa/auto-heal.sh scripts/qa/sync-compose-runtime.sh

git config core.hooksPath .githooks

echo "[hooks] installed: core.hooksPath=.githooks"
