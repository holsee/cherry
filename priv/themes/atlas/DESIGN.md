# Atlas theme — design system

The site is a map. The blog index is a plane you pan and zoom; every
post is a card placed inside its tag's region; the rest of the site is
a plotter-drawn survey sheet.

## World

- **Ground:** chart white (`#f4f6f2`) / night-chart navy (`#0b1417`),
  a hairline 3rem grid fixed behind everything; survey teal accent
  (`light-dark(#0b6e6e, #5ad1c4)`).
- **Face:** Geologica (variable 300-800, 22 KB latin subset, OFL) for
  every word; the system mono for dates, coordinates and legends.
- **Mast:** a title strip between a 2px and a 1px rule, uppercase.
- **Home:** a title block (sheet reference, site name at poster size,
  the description, "Open the map"), a north arrow in the corner.
- **The map (`/blog/`):** `post_list` groups posts by first tag into
  regions laid on a ring, each post on a staggered two-column grid
  inside its region; positions are emitted as CSS variables by the template, so
  the same content always draws the same map. `atlas-map.js` (~3 KB)
  adds `atlas-js` to `<html>` and moves the camera: drag and wheel
  pan, ctrl/cmd-wheel zoom, arrow keys pan, `+`/`-` zoom, `0`
  refits; focusing a card brings it into view; a minimap canvas draws
  every card and the camera window from the tokens; "List view"
  returns to the stacked rendering.

## Shipped templates

`layout` (the island), `page` (home title block), `post_list` (the map).
Everything else inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off:** regions are sections with a heading and a card grid.
   The page is complete.
2. **`prefers-reduced-motion`:** the camera moves without easing.
3. **Print:** the island flips to list view before printing; the grid
   ground is dropped.
