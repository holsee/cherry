#!/usr/bin/env bash
# Runs a command inside the cherry-dev container (the reference environment).
# Usage: scripts/devc.sh "mix ci"
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && (pwd -W 2>/dev/null || pwd))"
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "${root}:/workspace" \
  -v cherry-mix-home:/opt/mix \
  -v cherry-hex-home:/opt/hex \
  -w /workspace cherry-dev bash -c "$*"
