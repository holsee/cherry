# Brutalist theme — design system

The brutalist lane: the page shows its bones. No JavaScript of its own.

## World

- **Ground:** white / black; hyperlink blue by day
  (`#0000ee`), hazard yellow by night (`#ffe600`); the border token is
  the ink.
- **Faces:** Anton (static, 9 KB, OFL) for the name and headlines,
  uppercase, set to fill the width; system mono for everything else.
  52rem measure.
- **Layout:** the header is a slab - the name in a 3px box, a marquee
  ticker of the site description (one CSS animation, 30s), the nav as
  a row of boxes; the blog index is a table with ruled rows; every
  control is square; the footer is a box.

## Shipped templates

`layout` (slab), `post_list` (table). Everything else inherits from
the default theme (contract 1.1).

## Honest degradation

1. **`prefers-reduced-motion`:** the ticker stands still.
2. **Print:** black rules on white, ticker hidden.
