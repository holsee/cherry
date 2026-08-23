# Cinema theme — design system

The modern-landing lane with a video background. The hero is a
committed single look (white on film); the pages follow the tokens.

## World

- **Ground:** smoke (`#f2f2f2`) / carbon (`#0a0a0a`); cinema red
  accent (`light-dark(#c8102e, #ff3b4e)`).
- **The film:** `assets/hero.mp4` - a 960x540, 24 fps, 16 s palindrome
  loop (an abstract light study rendered with ffmpeg's `gradients`
  source and a vignette, H.264 CRF 30, 200 KB, silent) with
  `hero-poster.jpg` (5 KB) as the first frame. The `<video>` is
  `autoplay muted loop playsinline preload="metadata"`; an overlay
  gradient keeps the title legible. `cinema-hero.js` (~0.5 KB) pauses
  the film under `prefers-reduced-motion` or `saveData`, and when the
  hero is scrolled out of view.
- **Faces:** Big Shoulders Display (400-900, 24 KB) for titles,
  uppercase, condensed, at `clamp(4rem, 14vw, 12rem)` in the hero;
  Manrope (400-800, 21 KB) for prose. 44rem measure.
- **Layout:** the mast is transparent and white over the film on the
  home page (`.page-home`), solid elsewhere; posts open on a
  condensed title with a red rule.

## Shipped templates

`layout` (home-aware mast, island), `page` (the film hero on
`index.html`). Everything else inherits from the default theme
(contract 1.1).

## Honest degradation (in order)

1. **No autoplay / data saver / reduced motion:** the poster frame
   holds; the title card is complete.
2. **JS off:** the video plays by its own attributes; nothing else
   changes.
3. **Print:** video and overlay hidden, title in ink.

## Replacing the film

Theme assets win over a same-named static file, so the way to bring
your own film is `cherry theme.eject page` and pointing the `<video>`
(and its poster) at a file under `static/`; the overlay and the title
card need no change.
