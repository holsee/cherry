# Constellation theme — design system

The ThreeUI "Constellation Field" lane done Cherry's way: a living
particle sky behind a centred mast and a full-viewport home hero, every
star painted from the same tokens as the links.

## World

- **Ground:** pale sky (`#f7f8fc`) / observatory night (`#070a14`);
  cobalt accent (`light-dark(#2447d1, #7ea0ff)`) colours links and
  stars alike.
- **The field:** a fixed full-viewport canvas2d system
  (`constellation-field.js`, ~2 KB): up to 220 stars drifting, hairlines
  between neighbours under 120 px fading with distance, the pointer
  pulling the nearest stars. Paused when the tab is hidden.
- **Faces:** Unbounded (variable 400-900, 36 KB latin subset, OFL) for
  the mast, headings and the hero title; Geist (variable 400-700, 17 KB,
  OFL) for prose; system mono for structure.
- **Layout:** centred mast (uppercase tracked name, pill nav beneath on
  a glass strip), 44rem measure; the home page opens with a full-bleed,
  full-viewport hero (kicker, gradient-clipped title, lede, scroll cue)
  before the page body.

## Shipped templates

`layout` (the canvas and the island), `page` (the home hero when
`@doc.path == "index.html"`; any other page renders the default article).
Everything else inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off / no canvas:** the body paints a quiet radial gradient from
   the accent; the canvas stays invisible. Content is complete.
2. **`prefers-reduced-motion`:** one still sky, scroll cue static.
3. **Print:** canvas and cue hidden, the hero collapses to a heading, the
   gradient title becomes plain foreground ink.
