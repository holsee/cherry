---
title: Themes
description: The official Cherry themes, each shown in both renditions, with links to a live exhibition where every theme wears the same site.
---
# Themes

Thirty official themes ship inside the `cherry` binary. Every one is built from the same parts - a documented token manifest, `light-dark()` colour pairs, self-hosted fonts, zero third-party requests - so `theme: "NAME"` in `cherry.exs` is the whole migration, and your token overrides port across.

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

## atlas

The site is a map. The blog index is an infinite plane: every post is a card placed deterministically inside its tag's region, the regions ringed like contour islands; drag to pan, wheel to zoom, arrow keys for the keyboard, a minimap in the corner, a list view one click away. The rest is a plotter-drawn survey sheet with a title block and a north arrow. Geologica throughout.

<picture><source srcset="/images/themes/atlas-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/atlas-light.png" alt="The atlas theme blog index: post cards inside dashed tag regions on a grid, with a minimap" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/atlas/)

## bellows

One variable face, Anybody, whose width axis runs from 50 to 150, bound to the scroll position with CSS scroll-driven animations: the home opens on the site name pulled wide that narrows as it leaves, every heading widens as it enters, the mast compresses as you read down, index titles open up under the pointer. Not one line of script; browsers without scroll timelines see the designed resting widths.

<picture><source srcset="/images/themes/bellows-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/bellows-light.png" alt="The bellows theme home page: the site name set extremely wide in a heavy sans" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/bellows/)

## mercury

The Y2K lane done properly: a WebGL height field of drifting blobs shaded with a procedural chrome reflection sits in a band behind the mast, the pointer dents it, a click drops a ripple, and the home title is cast in the same metal. Dark bands, highlights and tint all come from the tokens. Below the band the page is matte and still, Lexend at weight 300.

<picture><source srcset="/images/themes/mercury-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/mercury-light.png" alt="The mercury theme home page: a liquid chrome surface behind a title filled with the same chrome" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/mercury/)

## flipdot

Every title arrives the way a split-flap board arrives, each cell cycling through glyphs before it settles, once, on entering view; the blog index is the board (date, title, tags, NEW or ON TIME); the site name runs along the top as the station sign. Doto, a dot-matrix variable face, draws every word out of dots on a ground of unlit dots. Prose stays on the system mono.

<picture><source srcset="/images/themes/flipdot-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/flipdot-light.png" alt="The flipdot theme blog index: amber dot-matrix titles on a black board with a status column" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/flipdot/)

## transit

The platform is the theme. Cross-document View Transitions carry a post's title from the index into the post page and back; a scroll timeline draws the reading progress under the mast; the post's title and meta sit in a left rail that stays with you while the body reads on the right. Not one line of script. Browsers without the APIs simply navigate.

<picture><source srcset="/images/themes/transit-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/transit-light.png" alt="The transit theme post page: a sticky title rail on the left, the body on the right" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/transit/)

## loom

The page is cloth on a loom: a simulated cloth hangs in a band behind the mast and ripples when the pointer brushes it or the page scrolls; the rules are warp threads; the nav hangs on the selvedge; the blog index is a weaver's draft, a row of cells per post encoding its tags with a key above. Young Serif headings over Atkinson Hyperlegible Next prose.

<picture><source srcset="/images/themes/loom-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/loom-light.png" alt="The loom theme blog index: rows of small filled cells beside serif titles under a woven band" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/loom/)

## topo

Relief. The whole page sits on a contour map drawn live: a layered noise field traced with marching squares at eight levels, drifting slowly, its amplitude dropping to zero under the reading column so the writing sits in a clearing while the land moves at the margins. Index contours in the accent, a scale bar in the footer. Alegreya for prose, Alegreya Sans for structure.

<picture><source srcset="/images/themes/topo-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/topo-light.png" alt="The topo theme post page: contour lines at both margins around a clear reading column" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/topo/)

## desktop

System 7 and Windows 98 chrome at real proportions: the page is a window with a pinstriped title bar, close and zoom gadgets, a bevelled frame and a button row, sitting on a stippled desktop; the blog index is a list view with Name, Date modified and Kind; 404 is a dialog with an OK button. Pixelify Sans for the chrome, the system stack for prose. No script of its own.

<picture><source srcset="/images/themes/desktop-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/desktop-light.png" alt="The desktop theme blog index: a classic OS window with a list view of posts on a grey stippled desktop" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/desktop/)

## swiss

The International Typographic Style, executed: a twelve-column grid faintly visible on the page and obeyed by every block; the name in the first columns, the nav from column four, the site name at poster size across eight columns with the description in the last four on the same baseline, the index as a numbered typographic table. Red, black, white. No radius, no shadow, no motion, no script.

<picture><source srcset="/images/themes/swiss-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/swiss-light.png" alt="The swiss theme home page: a huge flush-left name on a visible twelve-column grid with red links" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/swiss/)

## sketchbook

A field notebook: the page's structure is drawn by hand. Rules, underlines and the mast's baseline are wobbling strokes (an SVG mask on a token colour) that draw themselves as they scroll into view on a scroll timeline; the paper has grain; images are taped in at the corners. Shantell Sans, a face designed for exactly this, for display and notes; Atkinson Hyperlegible Next for prose. No script.

<picture><source srcset="/images/themes/sketchbook-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/sketchbook-light.png" alt="The sketchbook theme post page: a handwritten title with a wobbly blue underline on grainy paper" width="1200" height="750" loading="lazy"></picture>

[Live exhibition](https://themes.cherrybomb.dev/t/sketchbook/)
