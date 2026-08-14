# Default theme — design system

The category standard, played straight (user's standing choice, seed
`5f876708`). Quality bar: Bear Blog / Tufte CSS restraint, PaperMod /
Starlight dual-theme polish, gwern.net reading engineering, Stripe / Linear
spacing discipline. No editor cosplay, no smuggled quirk.

## World

- **Ground:** white (`#ffffff`) / near-black (`#15171b`) — truly dual: both
  renditions designed with equal weight; the toggle is a feature.
- **Faces:** Charter system-serif stack for prose (zero bytes over the wire);
  `ui-monospace` stack for structure — dates, nav, metadata, code. Mono is
  used only for code, data, and measurement, never as costume.
- **Accent:** one cherry red (`--color-accent`), links only. Restrained
  strategy: neutrals plus one accent — correct for a Read surface.
- **The memory moment:** code blocks. Raised quiet surface
  (`--color-surface`), hairline border, MDEx `html_linked` classes colored
  entirely by the theme's `--syn-*` tokens — the toggle swaps code and prose
  as one world, instantly, with no JS re-highlighting.

## Rules

- Every color lives in a token (`site.css` `:root` blocks); templates and
  component rules never carry a literal — test-enforced
  (`theme_tokens_test.exs`).
- Dark redefines every color token twice: under
  `prefers-color-scheme: dark` (guarded `:root:not([data-theme="light"])`)
  and under `:root[data-theme="dark"]`, so the manual toggle always beats
  system preference in both directions.
- Reading column: `--measure` 42rem (~66ch), 1.125rem/1.7 body.
- Spacing rhythm: more space above a heading than below it (h2: 2.5rem /
  0.75rem).
- The toggle island (`theme-toggle.ts`) fails soft: hidden until its script
  runs; without JS the site follows system preference. The no-flash script
  in `<head>` applies the stored choice before first paint.
- Tables scroll inside their own box on narrow screens; `pre` likewise.

## Token manifest

The authoritative list lives in `theme.exs` (`tokens:`) — name, default
(light rendition), and doc for every custom property. `cherry theme.list`
prints it.
