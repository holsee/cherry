#!/usr/bin/env bash
# Serve a built site from tmp/preview/_site at http://localhost:8123
#
#   scripts/preview.sh start   # (re)start nginx serving tmp/preview/_site
#   scripts/preview.sh stop
#
# Build something into it first, e.g.:
#   scripts/devc.sh "mix cherry.build --source test/fixtures/sites/folio --out tmp/preview/_site"
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && (pwd -W 2>/dev/null || pwd))"

case "${1:-start}" in
  start)
    docker rm -f cherry-preview >/dev/null 2>&1 || true
    MSYS_NO_PATHCONV=1 docker run -d --rm --name cherry-preview -p 8123:80 \
      -v "${root}/tmp/preview/_site:/usr/share/nginx/html:ro" nginx:alpine >/dev/null
    echo "preview at http://localhost:8123"
    ;;
  stop)
    docker rm -f cherry-preview >/dev/null 2>&1 || true
    echo "preview stopped"
    ;;
  *)
    echo "usage: preview.sh [start|stop]" >&2
    exit 2
    ;;
esac
