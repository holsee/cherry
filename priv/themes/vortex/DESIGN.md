# Vortex theme — design system

The ThreeUI "Typography Vortex" and text-path lanes: type is the only
ornament.

## World

- **Ground:** bone (`#f6f5f1`) / ink (`#0e0e10`); magenta accent
  (`light-dark(#d5006d, #ff5fa8)`).
- **The rings:** two SVG `<textPath>` circles carrying the site name,
  fixed off the right edge at 70vmin, counter-rotating on CSS
  animations (90s / 60s), muted ink at low opacity, the outer one in
  the accent on hover of nothing - it is atmosphere, not a control.
- **The landing:** `vortex-type.js` (~1 KB) splits each page's first h1
  into letter spans with staggered `animation-delay`; CSS does the
  rest. Without JS the title is simply whole.
- **Face:** Bricolage Grotesque (opsz 96, 200-800, 39 KB, OFL) for
  everything but code; titles at `clamp(3rem, 8vw, 7rem)`, weight 800,
  tracking -0.05em; prose at weight 400.
- **Layout:** mast top-left, nav inline, 44rem measure, the post list
  as oversized titles with the date as a hairline label.

## Shipped templates

`layout` only. Everything else inherits from the default theme
(contract 1.1).

## Honest degradation (in order)

1. **JS off:** rings turn (CSS), titles whole.
2. **`prefers-reduced-motion`:** rings still, letters land at once.
3. **Print:** rings hidden, titles in ink.
