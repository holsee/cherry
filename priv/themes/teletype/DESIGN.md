# Teletype theme — design system

The devlog theme for CLI-tool authors (catalog issue #112, #121): one
monospace face carries the whole page, so the writing sits in the same
fixed grid as the code it discusses. Quality bar: the default theme's
restraint wearing a terminal register honestly — no scanline cosplay,
no blinking cursors.

## World

- **Ground:** paper printout (`#fafaf7`) / amber-phosphor terminal
  (`#0f1210`) — the dark rendition is the identity, the light one is
  the same machine's paper trail.
- **Face:** Noto Sans Mono for everything — prose, structure, code —
  self-hosted 32 KB latin subset (OFL). `--font-prose` and
  `--font-mono` are identical by design; overriding either still works.
- **Accent:** warm CRT amber (`light-dark(#9a6700, #e3b341)`), links
  and heading markers.
- **Register, not costume:** headings wear their own markdown markers
  (`#`, `##`, `###` in accent via `::before`), rules are dashed
  perforation, blockquotes take a double border, and the footer reads
  as a status line on raised ground. Syntax colours are muted ANSI:
  green strings, amber keywords, cyan functions.

## Rules

- **CSS-only (contract 1.1).** `inherit_templates: true` — a manifest,
  a stylesheet, one font file. Every template resolves to the default
  theme's copy.
- Every color lives in a token; no literals outside token definitions
  (`theme_tokens_test.exs`, teletype is in the loop).
- Each color token is one `light-dark()` pair plus a plain light
  fallback; print forces the light rendition of the six print tokens.
- Token API identical to the default theme's key-for-key
  (`teletype_theme_test.exs`), so site overrides port across.
- Zero third-party requests; the heading markers are CSS `::before`
  content, invisible to copy/paste and search.
