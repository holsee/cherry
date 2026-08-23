# Cathode theme — design system

The ThreeUI "Cathode" and CRT lanes: the page is a tube. No JavaScript
of its own.

## World

- **Ground:** paper terminal (`#e8ecdf`) / phosphor on black
  (`#050806`); terminal green accent (`light-dark(#1d6b2d, #4dff6a)`).
- **The tube:** `.crt-scan`, a fixed `repeating-linear-gradient` of
  2px scanlines in the foreground colour at 6% (dark) mixed through
  `color-mix`, plus a radial vignette; `body` carries an inset box
  shadow as the bezel; headings get a `text-shadow` bloom in the dark
  rendition only (`:root[data-theme="dark"]` and the system dark
  query, via `color-scheme`-driven tokens). A `::after` block cursor
  blinks after every `h1`.
- **Face:** Azeret Mono (300-800, 22 KB, OFL) for everything; 40rem
  measure; prose at weight 350.
- **Layout:** the default layout inside a bezel; the mast reads as a
  status line (`> name`); nav items carry `[ ]` brackets.

## Shipped templates

`layout` only. Everything else inherits from the default theme
(contract 1.1).

## Honest degradation (in order)

1. **`prefers-reduced-motion`:** cursor solid, no flicker.
2. **Print:** scanlines, bezel and bloom off.
