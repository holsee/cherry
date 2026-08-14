# ADR 0004: Versioned theme contract with provenance-tracked overrides

**Status:** Accepted — 2026-08-14

## Context
Jekyll: shadowing works, but gem-hidden files + hand-copied overrides that silently
freeze. Hugo: lookup-order power became a specificity matrix confusing enough to
warrant the v0.146 overhaul. shadcn: open code + CLI metadata is right, but upstream
updates are an unanswered FAQ. WordPress child themes: customization in a separate
layer survives updates.

## Decision
A theme is a package (hex dep or plain directory — EEx evaluates at runtime, so binary
mode gets full themes) carrying a `theme.exs` manifest: contract version, template
inventory (fixed names + fixed assigns), token manifest. Customization ladder:
config → tokens → CSS append → `theme.eject` (records theme/version/hash provenance) →
own theme. `theme.diff` three-way-merges on upgrade; `cherry.check` flags stale
shadows. Lookup is three levels (site overlay → theme → framework), printable via
`theme.which`. Overlays are keyed per-theme so swaps never apply mismatched overrides.

## Consequences
Swapping is one config line and stays honest (Phase 2 ships a second official theme to
prove it). Never hand-copy a theme file — provenance is what makes upgrades mergeable.
Content must never reference theme internals; shortcodes are framework-level.
