# Transit theme — design system

The platform is the theme: cross-document View Transitions and CSS
scroll-driven animations, and not one line of script.

## World

- **Ground:** paper white (`#fbfbf9`) / graphite (`#0f1216`); signal
  blue accent (`light-dark(#0b5fff, #6ea8ff)`).
- **Face:** Gabarito (variable 400-900, 30 KB latin subset, OFL).
- **The transition:** `@view-transition { navigation: auto }` in the
  stylesheet; every index title and every post `h1` carry the same
  `view-transition-name` derived from the post's path, so the title
  travels between the two pages; `::view-transition-old/new(root)`
  cross-fade the rest over 260ms.
- **Progress:** `.transit-progress` is a 3px rule under the mast whose
  `scaleX` runs 0 to 1 on `animation-timeline: scroll(root)`.
- **The post:** a rail (title, date, tags, standfirst) on the left,
  sticky at desk width, the body on the right at the reading measure;
  stacked on phones.
- **The index:** a ruled list, date in a fixed left column.

## Shipped templates

`layout` (the progress rule), `post` (the rail), `post_list` (named
titles). Everything else inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **No cross-document View Transitions:** plain navigation.
2. **No scroll-driven animations:** the progress rule is a full rule.
3. **`prefers-reduced-motion`:** transitions and the timeline are off.
4. **Print:** the rail stacks above the body; no progress rule.
