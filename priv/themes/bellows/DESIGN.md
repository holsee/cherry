# Bellows theme — design system

Type that breathes. One variable face, Anybody, whose width axis is
bound to scroll with CSS scroll-driven animations. No script.

## World

- **Ground:** bone white (`#f6f4ee`) / ink blue (`#0e1226`); vermilion
  accent (`light-dark(#d7431b, #ff7a4d)`).
- **Face:** Anybody (wght 300-900, wdth 50-150; 50 KB latin subset,
  OFL) for everything but code.
- **The mechanism:** `animation-timeline: view()` on headings drives
  `font-variation-settings: "wdth"` from 80 as a heading enters to 115
  as it leaves; the home word runs 150 to 50 across its own exit; the
  mast title runs 125 to 75 over the first 320px of document scroll
  (`animation-timeline: scroll(root)`); index titles transition to
  wdth 125 on hover and focus.
- **Rules:** pleats, thin double lines (`border-style: double`).
- **Home:** the site name at wdth 150 across the viewport, the
  description, then the mast and the writing.

## Shipped templates

`page` (the home word). Everything else inherits from the default
theme (contract 1.1).

## Honest degradation (in order)

1. **No scroll-driven animations (Firefox at the time of writing):**
   every heading sits at its resting width. This is the designed page.
2. **`prefers-reduced-motion`:** the timelines are removed; resting
   widths everywhere.
3. **Print:** resting widths, no mast compression.
