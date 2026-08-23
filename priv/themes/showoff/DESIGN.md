# Showoff theme — design system

The "out there" one: every trick in the catalog, stacked on purpose, to
prove the contract holds under load.

## World

- **Ground:** orchid (`#fdf7ff`) / deep violet (`#07030f`); hot-pink
  accent (`light-dark(#e0107f, #ff4fa8)`) with the violet
  `--color-accent-strong` as the second colour of every gradient.
- **`showoff.js`** (~7 KB, one island, five parts, each guarded):
  1. **Aurora** - a WebGL fragment shader (3-octave value noise,
     curtains drifting) on a fixed full-viewport canvas, half
     resolution, ground/accent/strong through the probe bridge.
  2. **Comet** - a canvas2d trail of fading dots behind the pointer;
     off on coarse pointers and under reduced motion.
  3. **Magnetic nav** - links translate up to 6px toward the pointer
     within 80px and spring back.
  4. **Tilt** - `.so-card` index cards rotate up to 8° in 3D under the
     pointer with a moving highlight.
  5. **Reveal** - blocks rise into view (IntersectionObserver), only
     once `so-js` is on `<html>`.
- **Type:** Unbounded (400-900, 36 KB) for the mast, headings and the
  hero title (gradient-filled, `background-position` animated over
  8s); Instrument Serif italic (14 KB) for ledes and the first
  paragraph of a post; system sans prose. 46rem measure, index at
  64rem.
- **Layout:** glass mast; home hero (kicker, gradient title at
  `clamp(3rem, 9vw, 8rem)`, serif lede); a marquee strip of the site
  description after `<main>`; the blog index as tilting glass cards,
  the first spanning two columns; prose on a glass panel.

## Shipped templates

`layout`, `page` (home hero), `post_list` (cards). Everything else
inherits from the default theme (contract 1.1).

## Honest degradation (in order)

1. **JS off / no WebGL:** a CSS poster gradient; cards flat; every
   block visible; the marquee still runs (CSS) unless reduced motion.
2. **`prefers-reduced-motion`:** one aurora frame, no comet, no tilt,
   no magnetism, no marquee, no gradient motion, blocks whole.
3. **Print:** canvases, marquee hidden; gradient title in ink.
