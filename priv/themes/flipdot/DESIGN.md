# Flipdot theme — design system

The departure board. Titles flip in like a split-flap display, the
blog index is the board, every word is drawn from dots.

## World

- **Ground:** black board with amber dots (`#0a0a0a` / `#ffb020`) is the
  native rendition; the light rendition is the printed timetable
  (`#f2efe6` paper, `#b2570a` ink-amber). A dot grid (`radial-gradient`)
  sits on the body at 0.5rem pitch.
- **Faces:** Doto (variable wght 300-900, ROND 0-100; 5 KB, OFL) for
  the site name, headings, the nav and the board; system mono for
  prose, because dot matrix is for signs, not paragraphs.
- **The flip:** `flipdot-board.js` (~1.5 KB) wraps `[data-flip]`
  elements and every `main h1` into per-character cells when they
  enter the viewport and cycles each cell through A-Z 0-9 for 3-8
  ticks before it settles, left to right. Once, never looping. The
  element keeps its text as `aria-label`.
- **The board (`/blog/`):** a table: date, title, tags, status. The
  newest post reads NEW, the rest ON TIME. Deterministic: status
  depends on position, never on the clock.
- **Mast:** the station sign: the site name at the top in Doto, the nav
  as a row of cells.

## Shipped templates

`layout` (station sign + island), `post_list` (the board). Everything
else inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off:** every title is simply there; the board is a table.
2. **`prefers-reduced-motion`:** the island does nothing.
3. **Print:** the dot ground is dropped; the board prints as a table.
