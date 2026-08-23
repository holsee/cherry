# Isometric theme — design system

The ThreeUI "Isometric Motion Grid" lane: a perspective grid floor
under a left navigation rail. No JavaScript of its own.

## World

- **Ground:** frost (`#f4f7fb`) / graphite (`#0a0f14`); teal accent
  (`light-dark(#0f766e, #2dd4bf)`).
- **The floor:** `.site-header::after`, a 3D-transformed plane
  (`perspective` + `rotateX(62deg)`) carrying two crossed
  `linear-gradient` line patterns in the accent, `background-position`
  animated so the lines slide toward the viewer; masked to fade into
  the rail.
- **Face:** Sora (300-800, 32 KB, OFL) for everything but code.
- **Layout:** `body` is a two-column grid - the default layout's
  `<header>` becomes a sticky 16rem rail (name, nav stacked, toggle,
  search) with the floor at its foot; `<main>` and `<footer>` fill the
  right column on a 44rem measure. Under 56rem the rail folds into a
  top bar and the floor becomes a strip beneath it.

## Shipped templates

None. The whole theme is tokens + stylesheet on the default markup
(contract 1.1).

## Honest degradation (in order)

1. **`prefers-reduced-motion`:** the floor stands still.
2. **Print:** single column, floor off, rail hidden like any header.
