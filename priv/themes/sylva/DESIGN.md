# Sylva theme — design system

The ThreeUI "Sylva" living-world lane with its seasonal variants folded
into one theme: the canvas knows what month it is.

## World

- **Ground:** parchment (`#f6f4ec`) / forest floor (`#0f140f`); moss
  accent (`light-dark(#3f6b2e, #9ccc7a)`).
- **The season:** `sylva-season.js` (~2 KB) stamps `data-season` on
  `<html>` (spring Mar-May, summer Jun-Aug, autumn Sep-Nov, winter
  Dec-Feb; `?season=` overrides for previews) and drifts up to 90
  shapes - petals, leaves, amber leaves, snow - with sway and spin.
  The tint is **not in the script**: `.sylva-season` gets a `color`
  per season in the stylesheet, mixed from the tokens (`--syn-*` and
  the accent), and the canvas reads its own computed colour back.
- **Faces:** Newsreader (opsz 16, 400-700, 41 + 46 KB, OFL) upright
  and italic; system mono structure. 42rem measure.
- **Layout:** running head (name left, nav right) over a hairline; the
  blog index grouped under year headings with italic dates.

## Shipped templates

`layout` (canvas + island), `post_list` (grouped by year).
Everything else inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off / no canvas:** the forest floor, nothing moving.
2. **`prefers-reduced-motion`:** a few settled shapes, no loop.
3. **Print:** canvas hidden.
