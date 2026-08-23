#!/usr/bin/env bash
# theme_shots.sh — the theme QA screenshot harness (#115).
#
# Captures the standard page set of a running site at two viewports in
# both renditions, plus a print PDF of /cv/. Renditions ride the
# ?theme=light|dark query param every official layout honours before
# first paint, so no browser flag games are needed.
#
#   scripts/theme_shots.sh BASE_URL OUT_DIR [NAME=PATH ...]
#
#   BASE_URL   e.g. http://localhost:4001 (no trailing slash needed)
#   OUT_DIR    created if missing; files land as NAME-VIEWPORT-RENDITION.png
#   NAME=PATH  extra pages beyond the defaults, e.g. post=/blog/some-post/
#
# Defaults: home=/ blog=/blog/ cv=/cv/ timeline=/cv/timeline/ 404=/404.html
# Skip a default by passing NAME= (empty path). Browser autodetected from
# THEME_SHOTS_BROWSER, msedge (Windows), or google-chrome/chromium (Linux).

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 BASE_URL OUT_DIR [NAME=PATH ...]" >&2
  exit 2
fi

BASE="${1%/}"
OUT="$2"
shift 2

browser() {
  if [ -n "${THEME_SHOTS_BROWSER:-}" ]; then
    echo "$THEME_SHOTS_BROWSER"
    return
  fi
  for candidate in \
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
    "/c/Program Files/Microsoft/Edge/Application/msedge.exe" \
    "$(command -v google-chrome || true)" \
    "$(command -v chromium || true)" \
    "$(command -v chromium-browser || true)"; do
    if [ -n "$candidate" ] && [ -e "$candidate" ]; then
      echo "$candidate"
      return
    fi
  done
  echo "no headless browser found — set THEME_SHOTS_BROWSER" >&2
  exit 1
}

BROWSER="$(browser)"
mkdir -p "$OUT"

declare -A PAGES=(
  [home]="/"
  [blog]="/blog/"
  [cv]="/cv/"
  [timeline]="/cv/timeline/"
  [404]="/404.html"
)
for spec in "$@"; do
  name="${spec%%=*}"
  path="${spec#*=}"
  if [ -z "$path" ]; then
    unset "PAGES[$name]"
  else
    PAGES[$name]="$path"
  fi
done

with_theme() { # path rendition -> url
  case "$1" in
    *\?*) echo "$BASE$1&theme=$2" ;;
    *) echo "$BASE$1?theme=$2" ;;
  esac
}

# No --virtual-time-budget: a dev server's live-reload EventSource never
# closes, so virtual time never settles and the capture hangs forever.
# Plain --screenshot waits for load, which is enough for static pages.
shoot() { # url out_png width height out_dir
  "$BROWSER" --headless --disable-gpu --hide-scrollbars \
    --window-size="$3,$4" \
    --screenshot="$5/$2" "$1" 2>/dev/null
}

total=0
for name in "${!PAGES[@]}"; do
  path="${PAGES[$name]}"
  # A page a given site does not have (no CV, say) is skipped, not an error.
  status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE$path")
  if [ "$status" != "200" ] && [ "$name" != "404" ]; then
    echo "-- $name ($path) returned $status — skipping"
    continue
  fi
  for rendition in light dark; do
    url="$(with_theme "$path" "$rendition")"
    shoot "$url" "$name-desktop-$rendition.png" 1280 900 "$OUT"
    shoot "$url" "$name-mobile-$rendition.png" 390 844 "$OUT"
    total=$((total + 2))
  done
  echo "== $name ($path): 4 captures"
done

# Print rendition of the CV — the page that must survive paper.
if [ -n "${PAGES[cv]:-}" ]; then
  if [ "$(curl -s -o /dev/null -w "%{http_code}" "$BASE${PAGES[cv]}")" = "200" ]; then
    "$BROWSER" --headless --disable-gpu \
      --print-to-pdf="$OUT/cv-print.pdf" --no-pdf-header-footer \
      "$BASE${PAGES[cv]}" 2>/dev/null
    echo "== cv print PDF"
    total=$((total + 1))
  fi
fi

echo "done: $total captures in $OUT"
