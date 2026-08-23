# Warp theme — design system

The ThreeUI "Warp Field" lane: streaks of light rushing past, masked to a
band across the top of every page, the page title planted in them.

## World

- **Ground:** warm paper (`#fbf7f2`) / violet-black (`#08060f`); ember
  accent (`light-dark(#d4461c, #ff7a3d)`) colours links and streaks.
- **The field:** `warp-field.js` (~4 KB), a polar-streak fragment
  shader on an absolute band canvas (26rem tall, gradient-masked), half
  resolution, DPR-capped; it stops drawing once the band scrolls off.
- **Faces:** Syne (variable 400-800, 30 KB latin subset, OFL) for the
  mast, nav, headings and post-list titles; system sans prose; system
  mono structure. 46rem measure.
- **Layout:** transparent mast over the band; the first h1 of every page
  sits inside it; the post list is a rail of big titles with dates as
  tails.

## Shipped templates

`layout` only (canvas + island). Everything else inherits from the
default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off / no WebGL:** the body paints a CSS gradient band from the
   accent; the canvas stays invisible.
2. **`prefers-reduced-motion`:** one frame, then stillness.
3. **Print:** canvas hidden, band padding removed, plain ground.
