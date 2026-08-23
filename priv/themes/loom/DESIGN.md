# Loom theme — design system

The page is cloth on a loom: a simulated cloth behind the mast, warp
threads for rules, a weaver's draft for the index.

## World

- **Ground:** undyed linen (`#f4efe6`) / indigo (`#121826`); madder red
  accent (`light-dark(#a8322b, #e8705f)`).
- **Faces:** Young Serif (static, 16 KB, OFL) for headings and the site
  name; Atkinson Hyperlegible Next (variable, upright and italic, OFL)
  for prose at a generous leading.
- **The cloth:** `.loom-band` is an absolute 22rem band behind the mast
  (14rem on phones) holding a canvas; `loom-cloth.js` (~2.5 KB) runs a
  verlet grid (pinned along the top edge, ~48 x 18 points), pushed by
  the pointer and nudged by scroll velocity, drawn as warp and weft
  threads in `--color-fg` at low alpha over `--color-surface`, fading
  into `--color-bg` at the bottom.
- **Threads:** rules are `repeating-linear-gradient` warp lines rather
  than borders; the nav hangs on the selvedge (a dotted right edge).
- **The draft (`/blog/`):** each post row starts with a row of cells,
  one per tag in the site, filled where the post carries the tag; the
  key above the list names the columns and links to the tag pages.

## Shipped templates

`layout` (band + island), `post_list` (the draft). Everything else
inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off:** the band is a woven CSS texture from the tokens.
2. **`prefers-reduced-motion`:** the cloth is simulated once and hangs.
3. **Print:** the band is removed; the draft cells print as outlines.
