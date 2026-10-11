#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
CAPTURE_URL="${CAPTURE_URL:?Set CAPTURE_URL}"
CAPTURE_DIR="${CAPTURE_DIR:?Set CAPTURE_DIR}"
RUNTIME_DIR="${RUNTIME_DIR:-/home/runner/work/_temp/omgithub-runtime}"
# Validate inputs (exit 1 = script defect).
/usr/bin/time -p test -n "$CAPTURE_URL"
/usr/bin/time -p test -n "$CAPTURE_DIR"
/usr/bin/time -p test -f "$RUNTIME_DIR/scripts/default-capture.mjs"
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
# Open exact URL, wait for rendered content, capture desktop+mobile.
# default-capture.mjs: exit 75 = transient nav/browser infra failure, exit 1 = rendering/script defect.
/usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs"
# Verify outputs (exit 1 = rendering defect). Leaves app running.
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p ls -lh "$CAPTURE_DIR/final-desktop.png" "$CAPTURE_DIR/final-mobile.png"
