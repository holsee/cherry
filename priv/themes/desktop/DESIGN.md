# Desktop theme — design system

The retro OS, played straight: a window with a title bar, bevels, a
list view, a dialog. No script of its own.

## World

- **Ground:** the desktop is `--color-surface` under a 1-bit stipple
  (`#d6d6d6` platinum / `#353538`); the window content is `--color-bg`
  (white / `#1c1c1e`); highlight navy accent (`light-dark(#1b2fa8,
  #7fa2ff)`).
- **Faces:** Pixelify Sans (variable 400-700, 10 KB, OFL) for the title
  bar, the buttons, column headers and headings; the system stack for
  prose; the system mono for code.
- **The window:** `.window` wraps header, main and footer at 64rem; a
  2px bevel (light top-left, dark bottom-right) and a 1px outline; the
  title bar carries horizontal pinstripes with the name on a solid
  plate between close and zoom gadgets; the nav is a row of bevelled
  buttons; the footer is the status bar.
- **Controls:** every button and input is a bevel; focus is a dotted
  rectangle; active state inverts the bevel. Zero radius anywhere.
- **List view (`/blog/`):** Name / Date modified / Kind columns with
  bevelled headers, a document icon per row, row hover in the
  selection colour.
- **404:** a dialog with an alert icon, the message, OK and Blog.

## Shipped templates

`layout` (the window), `post_list` (list view), `not_found` (dialog).
Everything else inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off:** nothing changes; there is no script.
2. **`prefers-reduced-motion`:** nothing moves anyway.
3. **Print:** the desktop pattern and bevels go; the window prints as
   the page.
