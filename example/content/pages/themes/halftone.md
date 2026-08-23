---
title: "Using halftone"
description: "Install, override, and extend the halftone theme the Cherry way: its token API, its templates, and where each rung of the styling ladder applies."
---
## Using halftone

Risograph: halftone dot screens, hard offset shadows, poster cards and Archivo set wide and loud - a print shop with no JavaScript at all.

<figure class="theme-hero">
<picture><source srcset="/images/themes/halftone-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/halftone-light.png" alt="The halftone theme home page" width="1200" height="750"></picture>
<p class="theme-hero-actions"><a class="button" href="/t/halftone/">Live demo</a></p>
</figure>

Like every official theme in [the gallery](/themes/), halftone implements theme contract 1.1: every colour flows through the tokens below, the stylesheet lives in the `theme` cascade layer so your unlayered overrides always win, and any template it does not ship falls back to the default theme's copy.

### Install

One config line, or one command:

```elixir
# cherry.exs
theme: "halftone"
```

```text
$ cherry config theme halftone
```

Then `cherry build` (or `cherry serve` while you look around). Nothing else moves: your content, your overlays for other themes, and your token overrides for other themes stay where they are.

### The styling ladder, applied to halftone

Restyling costs exactly as much ownership as you choose to take. In order:

**Rung 1 - override a token.** The manifest below is halftone's public styling API. Overrides land in every page head, survive theme upgrades, and are validated against the manifest (a typo is an error, not a dead line):

```text
$ cherry config tokens.--color-accent "light-dark(#e63b2e, #ff6b5e)"
$ cherry theme.tokens        # shows the merged view
```

**Rung 2 - custom.css.** Drop `assets/custom.css` into your site and it links after the theme stylesheet and the tokens block on every page. halftone's own CSS lives in the `theme` cascade layer, so a plain selector in your unlayered file beats the theme without specificity games or `!important`.

**Rung 3 - overlay a template.** Write `themes/halftone/templates/<template>.html.eex` (or `.html.heex`) in your site and it shadows just that template.

**Rung 4 - eject.** `cherry theme.eject <template>` copies the original into that overlay directory with a provenance header, so `cherry theme.diff` can tell you forever after whether upstream moved under your copy.

**Rung 5 - a theme of your own.** `cherry gen.theme mytheme --from halftone` scaffolds the whole thing - manifest, templates, stylesheet - into `themes/mytheme/`, yours deliberately.

The [theming reference](/docs/theming/) covers every rung in depth; the [theme guide](/guides/creating-a-theme/) walks rung 5.

### Token API

Colour tokens are `light-dark()` pairs: one override sets both renditions, and the theme toggle flips a single `color-scheme` property.

#### Surface and text

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--color-bg` | `#fff7ec` | `#141414` | Page background. |
| `--color-surface` | `#f7ead8` | `#1f1d1a` | Raised ground: code blocks, inline code. |
| `--color-fg` | `#1a1a1a` | `#f2ead9` | Body text. |
| `--color-muted` | `#5c5248` | `#b0a597` | Secondary text: metadata, nav, footer. |
| `--color-border` | `#1a1a1a` | `#f2ead9` | Hairline rules and control borders. |
| `--color-accent` | `#e63b2e` | `#ff6b5e` | Links and interactive accents. |
| `--color-accent-strong` | `#b52418` | `#ff9a90` | Hover/active accent. |
| `--color-selection` | `#ffd5cf` | `#5a2520` | Text selection ground. |

#### Syntax highlighting

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--syn-keyword` | `#e63b2e` | `#ff6b5e` | Syntax: keywords. |
| `--syn-string` | `#1b6e3a` | `#6fd391` | Syntax: strings and characters. |
| `--syn-comment` | `#8a7f74` | `#8c8276` | Syntax: comments (italic). |
| `--syn-function` | `#6a2fb3` | `#c7a2ff` | Syntax: functions and methods. |
| `--syn-constant` | `#1d4fb8` | `#86b0ff` | Syntax: constants, numbers, booleans. |
| `--syn-type` | `#a85a00` | `#ffb660` | Syntax: types, modules, tags, attributes. |
| `--syn-variable` | `#1a1a1a` | `#f2ead9` | Syntax: variables and default code text. |
| `--syn-punct` | `#5c5248` | `#b0a597` | Syntax: punctuation and operators. |

#### Type and measure

| Token | Default | Role |
| --- | --- | --- |
| `--font-prose` | `'Archivo', system-ui, 'Segoe UI', Roboto, sans-serif` | Reading face (Archivo, self-hosted 29 KB latin subset, OFL). Headings use Archivo Expanded (21 KB). |
| `--font-mono` | `ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace` | Structure and code face. |
| `--measure` | `46rem` | Reading column width. |

### Templates

halftone ships 1 of the 9 templates in the contract; the rest resolve to the default theme's copy, so they stay current without you owning them. Overlay or eject any name in either list.

#### Shipped by halftone

| Template | Assigns | Purpose |
| --- | --- | --- |
| `post_list` | `@site`, `@posts` | Reverse-chronological index of published posts. |

#### Inherited from default

| Template | Assigns | Purpose |
| --- | --- | --- |
| `layout` | `@site`, `@inner`, `@page_title`, `@head_extra`, `@nav`, `@search`, `@page_class` | Outer HTML shell wrapped around every rendered page. |
| `page` | `@site`, `@doc` | A freeform page from the pages collection. |
| `post` | `@site`, `@doc` | A single blog post with title, date, and tags. |
| `tag` | `@site`, `@tag`, `@posts`, `@story_href` | Published posts carrying one tag; links to the tag's story when one exists. |
| `portfolio_timeline` | `@site`, `@portfolio`, `@cv_href` | The timeline mode of the profile: dated entries, open source; cv_href links the switcher back to the CV view when public. |
| `story` | `@site`, `@tag`, `@portfolio`, `@posts` | One tag across the whole story: portfolio entries plus blog posts. |
| `cv` | `@site`, `@cv` | The employer-shaped CV: cv-curated entries in the careers layout, print-first. |
| `not_found` | `@site` | The 404 page. |

### Working with an agent

Cherry ships [a skill](https://github.com/holsee/cherry/tree/develop/skills/cherry) that teaches a coding agent the operating loop above - the ladder, the CLI verbs, and the recovery playbook - so you can say *"make the accent electric blue, the Cherry way"* and it will reach for `cherry config tokens.--color-accent` instead of forking the stylesheet. Install it into your site's `.claude/skills/` (sites scaffolded with `cherry new` already carry `AGENTS.md` describing the same loop), then ask in terms of outcomes:

- *"Warm up halftone's palette for both renditions"* - the agent lists the manifest with `cherry theme.tokens`, overrides rung-1 tokens, and verifies with `cherry check`.
- *"Tighten the reading column"* - one token: `--measure`.
- *"Restyle the post list"* - rung 2 in `assets/custom.css` if CSS reaches it, `cherry theme.eject post_list` if structure has to change.

The one rule to hold an agent to: never edit the theme's own files under `themes/halftone/` unless they were ejected there on purpose - `cherry theme.diff` will name anything that drifts.
