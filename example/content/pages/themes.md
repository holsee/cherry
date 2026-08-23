---
title: Themes
description: The official Cherry themes, each shown in both renditions, with links to a live exhibition where every theme wears the same site.
---
# Themes

Twenty official themes ship inside the `cherry` binary. Every one is built from the same parts - a documented token manifest, `light-dark()` colour pairs, self-hosted fonts, zero third-party requests - so `theme: "NAME"` in `cherry.exs` is the whole migration, and your token overrides port across.

Each screenshot pair below follows your colour scheme; the [exhibition](https://themes.cherrybomb.dev) serves the same demo site once per theme, with identical routes, so you can swap mid-page.

## default

The category standard, played straight: Charter prose on a white/near-black dual ground, one cherry accent, zero webfonts. The theme a fresh `cherry new` site wears.

<picture><source srcset="/images/themes/default-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/default-light.png" alt="The default theme home page: quiet serif typography with a red accent" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/default/) · restyle it with the [themes guide](/guides/themes/)

## cherrybomb

The brand, and the theme this site wears: neon night wall by dark, poster paper by day, Noto Sans Mono where the code burns.

<picture><source srcset="/images/themes/cherrybomb-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/cherrybomb-light.png" alt="The cherrybomb theme home page: hot pink accents on a poster-paper ground" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/cherrybomb/)

## porcelain

Glazed-ceramic ground, Literata serif carrying everything, a sage accent applied like a maker's mark. CSS-only: a manifest, a stylesheet, and two font files - its templates inherit from the default theme, so there is nothing copied to drift.

<picture><source srcset="/images/themes/porcelain-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/porcelain-light.png" alt="The porcelain theme home page: warm ceramic white with sage green links" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/porcelain/)

## teletype

All-mono for the devlog crowd: Noto Sans Mono carries prose, structure, and code; paper printout by day, amber-phosphor terminal by night; headings wear their own markdown markers. Also CSS-only.

<picture><source srcset="/images/themes/teletype-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/teletype-light.png" alt="The teletype theme home page: monospace text with amber markdown heading markers" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/teletype/)

## prism

A live gradient mesh painted by a 5 KB hand-written WebGL shader, under glass surfaces. The mesh's colours come from the theme tokens through the [token to uniform bridge](/docs/theming/#theme-islands-and-tokens-beyond-css), so overriding `--color-accent` restyles the shader like a link. JS off gets a static poster gradient; reduced motion gets one still frame; print gets plain paper.

<picture><source srcset="/images/themes/prism-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/prism-light.png" alt="The prism theme home page: a violet gradient mesh behind a glass header" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/prism/)

## constellation

The ThreeUI constellation-field lane done Cherry's way: up to 220 stars drifting on a canvas2d field, hairlines forming between neighbours, the pointer pulling the nearest. A centred mast with a pill nav, a full-viewport home hero with a gradient-clipped title in Unbounded, Geist for prose. Every star is painted from the same tokens as the links.

<picture><source srcset="/images/themes/constellation-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/constellation-light.png" alt="The constellation theme home page: a star field behind a large gradient title" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/constellation/)

## warp

A warp field: a ~4 KB polar-streak shader on a band across the top of every page, the title set in Syne 800 inside it, the prose on still ground below. No WebGL gets a CSS gradient band; reduced motion freezes one frame.

<picture><source srcset="/images/themes/warp-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/warp-light.png" alt="The warp theme post page: orange light streaks behind a large Syne title" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/warp/)

## erosion

Sediment: up to 2,400 grains carried on a sin/cos flow field, drawn onto a canvas that is dimmed rather than cleared so deposits build and erode. Fraunces (soft, wonky, optical size 18) carries everything but code; the blog index is a two-column magazine grid with dates set large in italic.

<picture><source srcset="/images/themes/erosion-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/erosion-light.png" alt="The erosion theme blog index: a two-column serif grid over a drifting grain field" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/erosion/)

## vortex

Kinetic type, and nothing else: the site name runs around two counter-rotating SVG text rings pinned off the right edge, every page's first title lands letter by letter (a 1 KB island; the title is whole without it), and Bricolage Grotesque at its 96pt optical size carries the whole hierarchy.

<picture><source srcset="/images/themes/vortex-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/vortex-light.png" alt="The vortex theme blog index: oversized titles beside rotating rings of text" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/vortex/)

## halftone

A print shop with no JavaScript of its own: two dot screens laid down with CSS radial gradients and masks, 3px rules, hard offset shadows, the blog index as two-up poster cards that lift on hover, and Archivo Expanded in uppercase for every heading.

<picture><source srcset="/images/themes/halftone-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/halftone-light.png" alt="The halftone theme blog index: poster cards with hard black shadows on paper with a red dot screen" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/halftone/)

## isometric

The rail is the layout: name, nav, toggle and search stacked on the left over a 3D perspective grid floor whose lines slide toward the viewer, the writing on the right. All CSS on the default markup; under 56rem the rail folds to a top bar.

<picture><source srcset="/images/themes/isometric-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/isometric-light.png" alt="The isometric theme post page: a left navigation rail with a perspective grid floor beneath it" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/isometric/)

## sylva

The seasonal lane folded into one theme: petals in spring, leaves in summer, amber leaves in autumn, snow in winter, chosen by the month (or `?season=`). Each season's tint is a stylesheet rule over the tokens, read back by the canvas. Newsreader serif, a running-head mast, the blog index grouped under year headings.

<picture><source srcset="/images/themes/sylva-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/sylva-light.png" alt="The sylva theme blog index: green leaves drifting behind a serif list grouped by year" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/sylva/)

## tideform

Four layers of summed sines rolling across a band under the mast, far to near, each filled with the accent mixed deeper into the ground; the band scrolls away and the prose sits on dry ground. Schibsted Grotesk 800 titles, a tide-table index.

<picture><source srcset="/images/themes/tideform-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/tideform-light.png" alt="The tideform theme post page: layered blue waves under the header above a bold title" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/tideform/)

## cathode

The page is a tube: scanlines over everything, a bezel with an inset vignette, headings that bloom like phosphor in the dark rendition, a block cursor blinking after every title, the mast as a status line. Azeret Mono at weight 350 for prose. All stylesheet.

<picture><source srcset="/images/themes/cathode-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/cathode-light.png" alt="The cathode theme post page: green phosphor monospace text under scanlines with a blinking cursor" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/cathode/)

## kage

A page that behaves like a film: the home opens on a full-viewport title card, every block of every page rises into view as it is scrolled to, the mast slides away while you read down and returns on the way up, a gold hairline of progress crosses the top. Instrument Serif italic at poster size, Hanken Grotesk at weight 300 with generous leading. Dark is the native rendition.

<picture><source srcset="/images/themes/kage-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/kage-light.png" alt="The kage theme post page: a huge italic serif title on black velvet" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/kage/)

## broadsheet

The editorial lane: a masthead between a double rule and a single rule with the site's standfirst beneath it, the nav as a ruled row, the blog index as a three-column front page with column rules, datelines and standfirsts, posts opening on a drop cap. Playfair Display for the masthead and headlines, the system serif for body copy. Nothing moves.

<picture><source srcset="/images/themes/broadsheet-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/broadsheet-light.png" alt="The broadsheet theme blog index: a newspaper front page with a centred masthead and three columns" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/broadsheet/)

## brutalist

The page shows its bones: the name in a 3px box, a marquee ticker of the site description, the nav as a row of boxes, the blog index as a ruled table, Anton headlines set to fill the width, system mono for everything else. Hyperlink blue by day, hazard yellow by night.

<picture><source srcset="/images/themes/brutalist-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/brutalist-light.png" alt="The brutalist theme blog index: a black-bordered title box, a blue ticker strip and a ruled table" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/brutalist/)

## cinema

The video-background lane: the home page opens on a full-viewport, muted, looping film (a 200 KB abstract light study shipped with the theme, poster frame first) with the title cut across it in Big Shoulders Display and the mast floating transparent above; every other page is a quiet reader in Manrope. The film pauses under reduced motion, data saver, and out of view.

<picture><source srcset="/images/themes/cinema-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/cinema-light.png" alt="The cinema theme home page: a condensed white title over a dark red film still" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/cinema/)

## bento

The bento grid everyone recognises from product pages: the home is tiles (hero, the page body, a tile per section of the nav), the blog index is tiles with the newest post spanning two columns; rounded, softly shadowed, a small lift on hover. Onest does every weight.

<picture><source srcset="/images/themes/bento-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/bento-light.png" alt="The bento theme home page: rounded white tiles on a grey ground with a large title" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/bento/)

## showoff

The out-there one, on purpose: a WebGL aurora behind everything, a comet trail following the pointer, titles filled with a moving gradient, a marquee strip, nav links that lean toward the cursor, index cards that tilt in 3D, every block rising into view - stacked in one theme to prove that all of it runs on the same token API and the same contract as the quietest theme, reads as a complete page without JS, and goes still for anyone who asks.

<picture><source srcset="/images/themes/showoff-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/showoff-light.png" alt="The showoff theme home page: a pink-to-violet gradient title over an aurora with a serif italic lede" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/showoff/)
