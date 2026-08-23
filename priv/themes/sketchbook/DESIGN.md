# Sketchbook theme — design system

A field notebook: the page's structure is drawn by hand and draws
itself as you scroll. No script.

## World

- **Ground:** notebook white (`#fcfbf7`) / blackboard (`#1b1f22`);
  pencil-blue accent (`light-dark(#1f5fbf, #8ab4ff)`).
- **Faces:** Shantell Sans (variable 300-800, informality pinned at 40,
  OFL) for the site name, headings, captions and the footer; Atkinson
  Hyperlegible Next (variable, upright and italic, OFL) for prose.
- **Grain:** `.sk-grain` is a fixed layer of SVG `feTurbulence` noise
  (a data URI, grey only) at 7% opacity, `mix-blend-mode: multiply`
  in light and `screen` in dark.
- **The marks:** every rule is a hand-drawn stroke: an SVG path of a
  wobbling line used as a CSS mask on a pseudo-element filled with a
  token colour. Under the mast, under `h1`/`h2`, under index titles,
  around blockquotes. Each mark's width runs 0 to 100% on
  `animation-timeline: view()` over its own entry, so it draws as it
  arrives.
- **Tape:** figures and images get two rotated translucent strips at
  the top corners.

## Shipped templates

`layout` (the grain layer). Everything else inherits from the default
theme (contract 1.1).

## Honest degradation (in order)

1. **No scroll-driven animations:** every mark is drawn already.
2. **`prefers-reduced-motion`:** the same.
3. **Print:** grain and tape are dropped; the marks print.
