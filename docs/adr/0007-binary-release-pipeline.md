# ADR 0007: Binary release pipeline modeled on fizzy-cli

**Status:** Accepted — 2026-08-14 (ships with the Phase 3 binary)

## Context
People who skip the mix workflow need an idiomatic one-line install *and* upgrade
path. holsee/fizzy-cli proved the shape: tag push → gated release workflow →
per-platform binaries on GitHub Releases (checksums, provenance attestation) →
package-manager manifests → a checksum-verifying `install.sh` that resolves
`releases/latest`, so prereleases never reach casual installers.

Two things don't transfer from Go: GoReleaser (no Elixir support), and easy
cross-compilation — MDEx is a Rust NIF, and Burrito's Zig cross-builds would have to
get the right precompiled NIF per target.

## Decision
- **Tag push `v*` on `main` triggers release**; test gates run first; tag must be on
  `main` (fizzy's guard, verbatim idea).
- **Native-runner matrix, no cross-compilation**: ubuntu (+arm runner), macos
  (arm64 + x86_64), windows — each builds its own Burrito target. Sidesteps the NIF
  cross-compile trap entirely.
- **GitHub Releases** carry binaries + `SHA256SUMS` + `actions/attest-build-provenance`.
  Prerelease tags (`-beta1`, `-rc.1`) publish as prereleases, never "latest".
- **Install one-liner served from our own dogfood**:
  `curl -fsSL https://cherrybomb.dev/install.sh | sh` (Windows: `iwr … install.ps1 | iex`).
  The script detects OS/arch, resolves `releases/latest`, verifies checksums —
  fizzy's `scripts/install.sh` is the reference implementation.
- **Upgrade is first-class in the binary itself**: `cherry upgrade` checks
  `releases/latest`, downloads, verifies, swaps itself (rustup/deno style). Mix users
  upgrade via `mix deps.update cherry` as ever.
- **brew tap + scoop bucket** (`holsee/homebrew-tap` pattern) once the channel is
  proven; stable tags only, prereleases skip manifests.

## Consequences
Release engineering is a Phase 3 slice with real scope (matrix, signing/attestation,
installer, self-update) — budgeted, not bolted on. The project site (DO_NEXT slice 10)
hosts `install.sh`, so cherrybomb.dev is load-bearing for distribution, not just docs.
macOS signing/notarization can start absent (unsigned + documented) and upgrade later
without changing the pipeline shape.
