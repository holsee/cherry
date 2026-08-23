# Mercury theme — design system

Liquid metal. A WebGL chrome pool behind the mast on every page, the
home title cast in the same chrome, matte ground for the writing.

## World

- **Ground:** silver on white (`#f3f3f5`) / gunmetal on black
  (`#08090c`); violet accent (`light-dark(#4d3bd6, #a99bff)`) used as
  the tint in the reflection and for links.
- **The pool:** `.mercury-band` is an absolute 24rem band behind the
  mast (16rem on phones) holding a canvas; `mercury-pool.js` (~4 KB)
  renders a height field of four drifting blobs, the pointer's dent and
  a click ripple, shades it with a procedural chrome reflection whose
  dark bands, highlights and tint come from `--color-fg`,
  `--color-surface` and `--color-accent`, and fades into `--color-bg`
  at the bottom edge. DPR capped at 1.5; idles when the band is
  scrolled away.
- **Chrome type:** `.chrome-type` fills the home title with a
  `background-clip: text` metal ramp built from the same three tokens.
  Pinned by the brief (Y2K chrome lettering), not a default.
- **Faces:** Dela Gothic One (static, 12 KB, OFL) for display and the
  mast; Lexend (300-700, 25 KB, OFL) for prose at weight 300.
- **Shapes:** pills everywhere; the mast floats over the pool as a
  glass pill.

## Shipped templates

`layout` (band + island), `page` (the chrome title). Everything else
inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **No WebGL / JS off:** the band is a CSS chrome gradient from the
   same tokens.
2. **`prefers-reduced-motion`:** one still frame, no pointer dent.
3. **Print:** the band is removed; the chrome title prints as solid ink.
