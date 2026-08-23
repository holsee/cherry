# Tideform theme — design system

The ThreeUI "Tideform" and landscape lanes: a procedural horizon of
layered swell under the mast of every page.

## World

- **Ground:** salt (`#f3f7f9`) / deep water (`#061018`); sea-blue
  accent (`light-dark(#0b5fa5, #5cb5ff)`).
- **The tide:** `tide-waves.js` (~2 KB): four layers, each a sum of
  three sines with its own speed and amplitude, filled from the far
  layer (accent mixed 15% into the ground) to the near layer (60%),
  on an absolute 16rem band canvas that stops drawing once scrolled
  off. Colours through the probe bridge.
- **Face:** Schibsted Grotesk (400-900, 41 KB, OFL); titles at weight
  800, tight. 46rem measure.
- **Layout:** mast over the band, the page title on the "beach" below
  it; the post list as a tide table - date column in mono, titles
  heavy.

## Shipped templates

`layout` only. Everything else inherits from the default theme
(contract 1.1).

## Honest degradation (in order)

1. **JS off / no canvas:** a flat CSS horizon (two-tone gradient).
2. **`prefers-reduced-motion`:** one frozen swell.
3. **Print:** canvas hidden, band padding removed.
