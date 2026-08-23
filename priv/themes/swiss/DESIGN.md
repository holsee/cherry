# Swiss theme — design system

The International Typographic Style: a visible twelve-column grid,
flush-left asymmetry, red, black and white. No script.

## World

- **Ground:** white / black; one red (`light-dark(#e2001a, #ff2d3f)`)
  for links, the index numbers and a single rule under the mast.
- **Face:** Familjen Grotesk (variable 400-700, 15 KB, OFL) for all of
  it; the system mono for code only.
- **The grid:** `.swiss-grid` is a fixed layer of twelve hairline
  columns at the page width (`repeating-linear-gradient`), 7% alpha;
  every block is placed on it with CSS grid: the mast spans the row
  (name 1-3, nav 4-9, controls 10-12), the home name spans 1-8 at
  poster size and the description 9-12 on the same baseline, the
  reading measure sits in columns 4-10 at desk width.
- **Scale:** 1 : 1.5 (0.75 / 1 / 1.5 / 2.25 / 3.375 / 5rem), tight
  tracking on display sizes, hairline rules only on grid lines.
- **The index:** a table: number (red), date, title, tags.
- **Nothing else:** no radius, no shadow, no texture, no motion.

## Shipped templates

`layout` (the grid layer), `page` (the home composition), `post_list`
(the table). Everything else inherits from the default theme
(contract 1.1).

## Honest degradation (in order)

1. **JS off:** nothing changes; there is no script.
2. **`prefers-reduced-motion`:** nothing moves anyway.
3. **Print:** the grid layer is dropped.
