---
title: "Using isometric"
description: "Install, override, and extend the isometric theme the Cherry way: its token API, its templates, and where each rung of the styling ladder applies."
---
## Using isometric

A product site: left rail navigation over an animated isometric grid floor, teal on graphite, Sora throughout - all CSS.

See it live in the [exhibition](https://themes.cherrybomb.dev/t/isometric/), or back in [the gallery](/themes/). Like every official theme, isometric implements theme contract 1.1: every colour flows through the tokens below, the stylesheet lives in the `theme` cascade layer so your unlayered overrides always win, and any template it does not ship falls back to the default theme's copy.

### Install

One config line, or one command:

```elixir
# cherry.exs
theme: "isometric"
```

```text
$ cherry config theme isometric
```

Then `cherry build` (or `cherry serve` while you look around). Nothing else moves: your content, your overlays for other themes, and your token overrides for other themes stay where they are.

### The styling ladder, applied to isometric

Restyling costs exactly as much ownership as you choose to take. In order:

**Rung 1 - override a token.** The manifest below is isometric's public styling API. Overrides land in every page head, survive theme upgrades, and are validated against the manifest (a typo is an error, not a dead line):

```text
$ cherry config tokens.--color-accent "light-dark(#0f766e, #2dd4bf)"
$ cherry theme.tokens        # shows the merged view
```

**Rung 2 - custom.css.** Drop `assets/custom.css` into your site and it links after the theme stylesheet and the tokens block on every page. isometric's own CSS lives in the `theme` cascade layer, so a plain selector in your unlayered file beats the theme without specificity games or `!important`.

**Rung 3 - overlay a template.** Write `themes/isometric/templates/<template>.html.eex` (or `.html.heex`) in your site and it shadows just that template.

**Rung 4 - eject.** `cherry theme.eject <template>` copies the original into that overlay directory with a provenance header, so `cherry theme.diff` can tell you forever after whether upstream moved under your copy.

**Rung 5 - a theme of your own.** `cherry gen.theme mytheme --from isometric` scaffolds the whole thing - manifest, templates, stylesheet - into `themes/mytheme/`, yours deliberately.

The [theming reference](/docs/theming/) covers every rung in depth; the [theme guide](/guides/creating-a-theme/) walks rung 5.

### Token API

Colour tokens are `light-dark()` pairs: one override sets both renditions, and the theme toggle flips a single `color-scheme` property.

#### Surface and text

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--color-bg` | `#f4f7fb` | `#0a0f14` | Page background. |
| `--color-surface` | `#e9eef5` | `#121a22` | Raised ground: code blocks, inline code. |
| `--color-fg` | `#0f1720` | `#e4ecf3` | Body text. |
| `--color-muted` | `#55657a` | `#92a3b5` | Secondary text: metadata, nav, footer. |
| `--color-border` | `#d6dde8` | `#1f2b38` | Hairline rules and control borders. |
| `--color-accent` | `#0f766e` | `#2dd4bf` | Links and interactive accents. |
| `--color-accent-strong` | `#0b5a54` | `#7ee8da` | Hover/active accent. |
| `--color-selection` | `#c8ece8` | `#12403b` | Text selection ground. |

#### Syntax highlighting

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--syn-keyword` | `#0f766e` | `#2dd4bf` | Syntax: keywords. |
| `--syn-string` | `#a1431c` | `#ffb088` | Syntax: strings and characters. |
| `--syn-comment` | `#7d8a9c` | `#7b8a9b` | Syntax: comments (italic). |
| `--syn-function` | `#5b3bc4` | `#c4b0ff` | Syntax: functions and methods. |
| `--syn-constant` | `#1f5fc4` | `#8fb8ff` | Syntax: constants, numbers, booleans. |
| `--syn-type` | `#9b2c6f` | `#ff8ac7` | Syntax: types, modules, tags, attributes. |
| `--syn-variable` | `#0f1720` | `#e4ecf3` | Syntax: variables and default code text. |
| `--syn-punct` | `#55657a` | `#92a3b5` | Syntax: punctuation and operators. |

#### Type and measure

| Token | Default | Role |
| --- | --- | --- |
| `--font-prose` | `'Sora', system-ui, 'Segoe UI', Roboto, sans-serif` | Reading and display face (Sora, self-hosted 32 KB latin subset, OFL). |
| `--font-mono` | `ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace` | Structure and code face. |
| `--measure` | `44rem` | Reading column width. |

### Templates

isometric ships no templates of its own: all 9 in the contract resolve to the default theme's copy, so its whole voice is CSS and every template stays current without you owning it. Overlay or eject any name in either list.

#### Shipped by isometric

_None - every template is the theme's own._

#### Inherited from default

| Template | Assigns | Purpose |
| --- | --- | --- |
| `layout` | `@site`, `@inner`, `@page_title`, `@head_extra`, `@nav`, `@search`, `@page_class` | Outer HTML shell wrapped around every rendered page. |
| `page` | `@site`, `@doc` | A freeform page from the pages collection. |
| `post` | `@site`, `@doc` | A single blog post with title, date, and tags. |
| `post_list` | `@site`, `@posts` | Reverse-chronological index of published posts. |
| `tag` | `@site`, `@tag`, `@posts`, `@story_href` | Published posts carrying one tag; links to the tag's story when one exists. |
| `portfolio_timeline` | `@site`, `@portfolio`, `@cv_href` | The timeline mode of the profile: dated entries, open source; cv_href links the switcher back to the CV view when public. |
| `story` | `@site`, `@tag`, `@portfolio`, `@posts` | One tag across the whole story: portfolio entries plus blog posts. |
| `cv` | `@site`, `@cv` | The employer-shaped CV: cv-curated entries in the careers layout, print-first. |
| `not_found` | `@site` | The 404 page. |

### Working with an agent

Cherry ships [a skill](https://github.com/holsee/cherry/tree/develop/skills/cherry) that teaches a coding agent the operating loop above - the ladder, the CLI verbs, and the recovery playbook - so you can say *"make the accent electric blue, the Cherry way"* and it will reach for `cherry config tokens.--color-accent` instead of forking the stylesheet. Install it into your site's `.claude/skills/` (sites scaffolded with `cherry new` already carry `AGENTS.md` describing the same loop), then ask in terms of outcomes:

- *"Warm up isometric's palette for both renditions"* - the agent lists the manifest with `cherry theme.tokens`, overrides rung-1 tokens, and verifies with `cherry check`.
- *"Tighten the reading column"* - one token: `--measure`.
- *"Restyle the post list"* - rung 2 in `assets/custom.css` if CSS reaches it, `cherry theme.eject post_list` if structure has to change.

The one rule to hold an agent to: never edit the theme's own files under `themes/isometric/` unless they were ejected there on purpose - `cherry theme.diff` will name anything that drifts.
