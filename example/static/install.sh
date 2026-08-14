#!/bin/sh
# cherry installer — https://cherrybomb.dev/install.sh (ADR 0007)
# Detects OS/arch, resolves the latest stable release, verifies the
# SHA-256 checksum, installs to ~/.local/bin (or $CHERRY_INSTALL_DIR).
set -eu

repo="holsee/cherry"
install_dir="${CHERRY_INSTALL_DIR:-$HOME/.local/bin}"

os=$(uname -s)
arch=$(uname -m)

case "$os" in
  Linux) os=linux ;;
  Darwin) os=macos ;;
  *) echo "error: unsupported OS: $os (Windows: iwr https://cherrybomb.dev/install.ps1 | iex)" >&2; exit 1 ;;
esac

case "$arch" in
  x86_64 | amd64) arch=x86_64 ;;
  aarch64 | arm64) arch=aarch64 ;;
  *) echo "error: unsupported architecture: $arch" >&2; exit 1 ;;
esac

asset="cherry-$os-$arch"

# releases/latest never resolves a prerelease — casual installs stay stable.
base="https://github.com/$repo/releases/latest/download"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "downloading $asset (latest stable)..."
curl -fsSL -o "$tmp/$asset" "$base/$asset"
curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"

echo "verifying checksum..."
expected=$(grep " $asset\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)
if [ -z "$expected" ]; then
  echo "error: $asset not found in SHA256SUMS" >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$tmp/$asset" | cut -d' ' -f1)
else
  actual=$(shasum -a 256 "$tmp/$asset" | cut -d' ' -f1)
fi

if [ "$expected" != "$actual" ]; then
  echo "error: checksum mismatch for $asset" >&2
  echo "  expected: $expected" >&2
  echo "  actual:   $actual" >&2
  exit 1
fi

mkdir -p "$install_dir"
install -m 755 "$tmp/$asset" "$install_dir/cherry"

echo "installed cherry to $install_dir/cherry"
case ":$PATH:" in
  *":$install_dir:"*) ;;
  *) echo "note: add $install_dir to your PATH" ;;
esac
"$install_dir/cherry" version
