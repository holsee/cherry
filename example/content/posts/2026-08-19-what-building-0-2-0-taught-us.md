---
title: What building 0.2.0 taught us
description: Styling as a ladder, light and dark as one value, components that survive theme swaps, and the HEEx spike with its real numbers.
tags:
  - design
  - release
---
0.2.0 was the "innovation" release: templates and styling, the two places where static site generators traditionally make you choose between someone else's taste and a fork. We went in with one rule: nothing we ship should feel alien to someone who lives in modern CSS and Phoenix. Here is what we built, and what building it taught us.

## Styling wanted to be a ladder

The old menu was two items: override nothing, or own everything. We kept asking "what is the smallest amount of ownership that solves this?" and the answers arranged themselves into rungs:

1. **A token.** `cherry config tokens.--color-accent "#7c3aed"` and the whole world follows, code blocks included. Validated against the theme's manifest, so a typo names the nearest real token instead of dying silently in your config.
2. **A stylesheet.** `assets/custom.css` loads last, always. We put the official theme CSS in `@layer theme`, so your unlayered rules win by cascade rules, not specificity arms races. The platform had already solved this fight; we just had to stop fighting.
3. **One template.** Overlay it, in either language.
4. **Ownership with a receipt.** `theme.eject` and provenance, as before.
5. **Your own theme.** `gen.theme` scaffolds the whole thing.

The lesson: every support question of the form "how do I change X" is really "which rung is X on", and a good tool should make the answer one sentence. That is [the theming docs](/docs/theming/) now.

## light-dark() deleted a third of our CSS problem

Both official themes used to carry three synchronised copies of every colour decision: light, dark via media query, dark via toggle. The modern platform primitive collapses all of it. Each token is now one pair:

```css
--color-accent: light-dark(#c0134f, #ff4d7d);
```

and the theme toggle flips a single `color-scheme` property. No duplicate blocks, no class soup, no flash. Printing from a forced-dark page gets the complete light rendition, including syntax colours, which the old three-block scheme could never quite reach. Engines without support get the full light rendition behind `@supports`, never broken colours.

The lesson: when the platform grows a primitive that models your exact problem, delete your workaround with prejudice. We even gate it in CI now: a test counts the token declarations per rendition and fails if anyone reintroduces a synchronised copy.

## Components had to belong to the framework, not the theme

Figures with captions, video embeds, callouts: every site wants them, markdown does none of them well, and if a theme provides them then swapping themes breaks your content. So they are framework-level directives, expanded before markdown, styled by whatever theme is active:

```text
::video{youtube="q6Yr9DkTn2k" title="Backpressure in practice"}
```

That video renders a facade that makes zero third-party requests until clicked; a 500-byte island swaps in a `youtube-nocookie` iframe on demand. And a misused component is a `check` diagnostic that names the file and the problem, never a broken build. The pipeline position even fixed a bug class for free: component `src` paths pick up `base_path` rewriting, which raw HTML in markdown never did.

## The HEEx spike, with numbers

The oldest open question in the design doc was template languages: EEx (simple, everywhere) versus HEEx (checked, componentized, Phoenix-shaped). We refused to decide by taste, so we ran a spike: can the full HEEx pipeline (compile, eval, render, function components) run at runtime inside a Burrito-packed release, and what does it cost?

The verdict: yes, cleanly. About 4.9MB of uncompressed release libs (roughly 1 to 1.5MB on the shipped binary), and about half a millisecond per template render, so a hundred-page site pays around 50ms. For that you get escaping by default, compile-checked markup with file, line:column, and a caret when you typo a tag, and `<.card title={@title}>` resolving the way a Phoenix developer expects, from a `components.exs` your theme carries.

So the answer to "EEx or HEEx" became: **that is not a decision, that is a file extension.** `.heex` outranks `.eex` at the same lookup level; official themes stay EEx; the HEEx lane belongs to overlays, rewrites, and [themes of your own](/guides/creating-a-theme/). Provenance stayed honest along the way: a HEEx rewrite reports as `rewritten` (yours outright, no three-way merge pretends otherwise), and the `.eex` it shadows reports as `shadowed` instead of lying about being current.

The lesson: spikes with numbers end arguments that taste never will.

## And the boring one: the mobile bar

A Playwright sweep at 360 and 390 pixels found our nav links standing 22px tall against WCAG's 24px floor, and a search input small enough to make iOS Safari zoom the page on focus. Both themes now expand tap targets with padding plus negative margin (zero layout shift, 40px targets) and pin the search input to 16px at coarse pointers. Seventy-eight screenshots across both themes, both renditions, three widths: zero horizontal overflow.

The lesson there is the oldest one: measure, do not assert. It is the same lesson as the spike, wearing sensible shoes.

All of it is in [the docs](/docs/), and all of it ships in 0.2.0.
