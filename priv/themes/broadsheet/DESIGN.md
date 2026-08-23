# Broadsheet theme — design system

The editorial lane: a broadsheet. No JavaScript of its own; nothing
moves.

## World

- **Ground:** newsprint (`#f9f7f1`) / late edition (`#141311`); oxblood
  accent (`light-dark(#8a1c1c, #e36b6b)`); the border token is the
  ink, so rules print as rules.
- **Faces:** Playfair Display upright + italic (400-900, 34 + 33 KB,
  OFL) for the masthead (weight 900, 4rem) and headlines; system
  serif body copy; mono datelines. 46rem measure (the front page
  widens to 64rem).
- **Layout:** the masthead replaces the default header - centred name
  between a double rule and a single rule, the standfirst (site
  description) in italic, the nav as a ruled row. The blog index is
  the front page: three columns (`column-count`) with column rules,
  each lead carrying a dateline, headline and standfirst, the first
  paragraph of a post opening on a drop cap.

## Shipped templates

`layout` (masthead), `post_list` (front page). Everything else
inherits from the default theme (contract 1.1).

## Honest degradation

1. **Narrow screens:** the front page drops to two columns under
   56rem and one under 36rem.
2. **Print:** already print-shaped; the masthead stays.
