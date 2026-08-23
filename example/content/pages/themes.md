---
title: Themes
description: The official Cherry themes, each shown in both renditions, with links to a live exhibition where every theme wears the same site.
---
# Themes

Five official themes ship inside the `cherry` binary. Every one is built from the same parts - a documented token manifest, `light-dark()` colour pairs, self-hosted fonts, zero third-party requests - so `theme: "NAME"` in `cherry.exs` is the whole migration, and your token overrides port across.

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

## Make any of them yours

Every theme publishes its tokens as an API - list them with `cherry theme.tokens`, override them from `cherry.exs`, and climb the [styling ladder](/docs/theming/) as far as you want to go. `cherry gen.theme mine --from porcelain` hands you a complete, self-contained copy to own outright.
