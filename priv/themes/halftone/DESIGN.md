# Halftone theme — design system

The ThreeUI "Halftone" lane as a print shop: dot screens, hard shadows,
poster cards, expanded caps. No JavaScript of its own.

## World

- **Ground:** paper (`#fff7ec`) / pressroom (`#141414`); riso red
  accent (`light-dark(#e63b2e, #ff6b5e)`); the border token *is* the
  ink (fg) so every rule is a printed rule.
- **The screens:** two `radial-gradient` dot patterns on `body::before`
  (ink dots, 7px pitch) and `body::after` (accent dots, 11px pitch),
  each faded with a `mask-image` gradient from a corner. Pure CSS.
- **Faces:** Archivo (400-900, 29 KB) prose; Archivo Expanded (wdth
  125, 700-900, 21 KB) for headings, uppercase, tight. OFL.
- **Layout:** mast on a 3px rule; 46rem measure; the blog index is a
  two-up grid of poster cards (3px border, 6px hard offset shadow,
  hover lifts the card and grows the shadow); code blocks get the same
  hard border.

## Shipped templates

`post_list` only. Everything else inherits from the default theme
(contract 1.1).

## Honest degradation (in order)

1. **No `mask-image`:** the screens fall back to a plain ground
   (guarded by `@supports`).
2. **`prefers-reduced-motion`:** hover lift off.
3. **Print:** screens off, shadows off, cards single column.
