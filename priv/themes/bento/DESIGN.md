# Bento theme — design system

The alternate-modern lane: a bento grid. No JavaScript of its own.

## World

- **Ground:** fog (`#f5f5f7`) with white tiles / true black with
  graphite tiles (`#1c1c1e`); cobalt accent
  (`light-dark(#0066cc, #2997ff)`).
- **Tiles:** `.tile` - surface colour, 1.5rem radius, a soft shadow
  from the foreground colour at 6%, 1px border; hover lifts 2px and
  deepens the shadow (160ms). The `.bento` grid is 12 columns at
  64rem, collapsing to 6 then 1.
- **Face:** Onest (300-900, 30 KB, OFL) throughout; titles at weight
  800, tight; prose at 400.
- **Layout:** the home page is tiles - hero (name, lede; spans 7
  columns), the page body (spans 5 then full), and a tile per nav
  item (from the layout, which knows `@nav`); the blog index is
  tiles - the newest post spans 8 columns, the rest 4 - each with
  date, title and description.

## Shipped templates

`layout` (nav tiles on `page-home`), `page` (home tiles),
`post_list` (index tiles). Everything else inherits from the default
theme (contract 1.1).

## Honest degradation

1. **`prefers-reduced-motion`:** no lift.
2. **Print:** tiles stack, shadows off.
