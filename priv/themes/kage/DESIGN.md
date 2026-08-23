# Kage theme — design system

The ThreeUI "Kage" landing lane: a page that behaves like a film.
Dark is the native rendition.

## World

- **Ground:** ivory (`#f4f2ec`) / black velvet (`#0b0b0c`); gold accent
  (`light-dark(#8a6a1f, #c9a45c)`).
- **The scenes:** `kage-scenes.js` (~1.5 KB) adds `kage-js` to `<html>`
  (so nothing is hidden without it), observes every direct child of
  the article and the profile, stamps `is-seen` with a small stagger,
  drives the progress hairline from scroll position, and toggles
  `is-hidden` on the mast when scrolling down past 120px.
- **Faces:** Instrument Serif italic (static, 14 KB) for titles at
  `clamp(3rem, 9vw, 7.5rem)`; Hanken Grotesk (300-800, 27 KB) prose at
  weight 300, 1.8 leading; system mono structure. 40rem measure.
- **Layout:** a fixed, fading mast; the home page opens on a
  full-viewport title card (italic title, lede, a single gold rule);
  posts open on the poster-size title.

## Shipped templates

`layout` (hairline + island), `page` (the home title card).
Everything else inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off:** everything visible at once, mast static, no hairline.
2. **`prefers-reduced-motion`:** no transitions; blocks appear whole.
3. **Print:** hairline off, mast hidden, title card collapses.
