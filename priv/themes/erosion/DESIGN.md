# Erosion theme — design system

The ThreeUI "Recursive Erosion" lane: a slow flow field of grains behind
a soft-serif magazine layout.

## World

- **Ground:** limestone (`#f1f0ea`) / wet slate (`#0e1311`); verdigris
  accent (`light-dark(#2e7264, #6fcfb6)`) for links and the brightest
  grains.
- **The sediment:** `erosion-grains.js` (~2 KB): up to 2,400 grains on a
  sin/cos flow field, drawn as 1px rectangles with additive fading and
  a persistent trail (the canvas is dimmed rather than cleared), so
  deposits build and erode. Pointer moves the flow's centre.
- **Faces:** Fraunces (opsz 18, SOFT 50, WONK, 300-700, 34 + 43 KB,
  OFL) for everything but code; italic dates set large in the index.
- **Layout:** mast with a hairline rule, 48rem measure, the blog index
  as a two-column grid of entries (one column under 52rem).

## Shipped templates

`layout` (canvas + island), `post_list` (the magazine grid, with the
post description when one exists). Everything else inherits from the
default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off / no canvas:** clean stone; the canvas stays invisible.
2. **`prefers-reduced-motion`:** one settled deposit, no loop.
3. **Print:** canvas hidden; the index collapses to one column.
