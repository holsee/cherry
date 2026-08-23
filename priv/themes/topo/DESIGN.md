# Topo theme — design system

Relief. A live contour map behind the page that goes flat under the
reading column.

## World

- **Ground:** pale olive survey paper (`#eef0e4`) / night relief
  (`#151a12`); burnt sienna accent (`light-dark(#b5451b, #e0895a)`).
- **Faces:** Alegreya (variable, upright and italic) for prose at
  1.0625rem; Alegreya Sans (regular and bold) for the mast, nav,
  headings and meta. One family, two voices.
- **The relief:** `.topo-relief` is a fixed full-viewport canvas at
  `z-index: -1`; `topo-relief.js` (~3 KB) builds a three-octave value
  noise field on a 14px cell grid, drifts it with time, multiplies its
  amplitude by a smooth distance to the `main .wrap` rectangle (the
  clearing) and traces eight levels with marching squares. Every
  fourth level is an index contour at higher alpha. Colours from
  `--color-fg` and `--color-accent` over `--color-bg`. Half the levels
  on phones.
- **The mast:** name in Alegreya Sans bold, the nav as small caps.
- **Footer:** a scale bar (four alternating bars and the contour
  interval), CSS only.

## Shipped templates

`layout` (canvas, island, scale bar). Everything else inherits from the
default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off:** a still contour texture from CSS radial gradients.
2. **`prefers-reduced-motion`:** one frame, no drift.
3. **Print:** no relief; the scale bar prints.
