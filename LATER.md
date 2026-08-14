# LATER — parked, not lost

- Generated OG card images (vix/libvips or resvg) — static fallback is fine for now.
- Shortcodes/components in markdown (Zola-style) — transform-stage feature, Phase 2+.
- Incremental builds beyond serve-mode — full builds are fast enough at blog scale.
- Burrito binary release channel (ADR 0007, with the Phase 3 binary): tag-triggered
  matrix workflow, GitHub Releases + checksums + attestation, install.sh served from
  cherrybomb.dev, `cherry upgrade` self-update, brew/scoop manifests. Reference:
  fizzy-cli's release.yml + scripts/install.sh + RELEASING.md.
- macOS signing + notarization for the binary (start unsigned + documented).
- HEEx layouts (would pull phoenix_live_view dep) — revisit only if EEx proves limiting.
- Theme gallery/registry page once a second+ theme exists.
- Claim `cherry` on Hex early (needs a publishable 0.0.x stub) — decide when bootstrap
  lands.
- i18n/multilingual content — watch for demand; Pagefind side is zero-config already.
