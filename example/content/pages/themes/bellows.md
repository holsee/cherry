---
title: "Using bellows"
description: "Install, override, and extend the bellows theme the Cherry way: its token API, its templates, and where each rung of the styling ladder applies."
---
## Using bellows

Type that breathes: Anybody's width axis is bound to scroll, so every title widens and narrows as it passes; pure CSS, no script.

See it live in the [exhibition](https://themes.cherrybomb.dev/t/bellows/), or back in [the gallery](/themes/). Like every official theme, bellows implements theme contract 1.1: every colour flows through the tokens below, the stylesheet lives in the `theme` cascade layer so your unlayered overrides always win, and any template it does not ship falls back to the default theme's copy.

### Install

One config line, or one command:

```elixir
# cherry.exs
theme: "bellows"
```

```text
$ cherry config theme bellows
```

Then `cherry build` (or `cherry serve` while you look around). Nothing else moves: your content, your overlays for other themes, and your token overrides for other themes stay where they are.

### The styling ladder, applied to bellows

Restyling costs exactly as much ownership as you choose to take. In order:

**Rung 1 - override a token.** The manifest below is bellows's public styling API. Overrides land in every page head, survive theme upgrades, and are validated against the manifest (a typo is an error, not a dead line):

```text
$ cherry config tokens.--color-accent "light-dark(#d7431b, #ff7a4d)"
$ cherry theme.tokens        # shows the merged view
```

**Rung 2 - custom.css.** Drop `assets/custom.css` into your site and it links after the theme stylesheet and the tokens block on every page. bellows's own CSS lives in the `theme` cascade layer, so a plain selector in your unlayered file beats the theme without specificity games or `!important`.

**Rung 3 - overlay a template.** Write `themes/bellows/templates/<template>.html.eex` (or `.html.heex`) in your site and it shadows just that template.

**Rung 4 - eject.** `cherry theme.eject <template>` copies the original into that overlay directory with a provenance header, so `cherry theme.diff` can tell you forever after whether upstream moved under your copy.

**Rung 5 - a theme of your own.** `cherry gen.theme mytheme --from bellows` scaffolds the whole thing - manifest, templates, stylesheet - into `themes/mytheme/`, yours deliberately.

The [theming reference](/docs/theming/) covers every rung in depth; the [theme guide](/guides/creating-a-theme/) walks rung 5.

### Token API

Colour tokens are `light-dark()` pairs: one override sets both renditions, and the theme toggle flips a single `color-scheme` property.

#### Surface and text

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--color-bg` | `#f6f4ee` | `#0e1226` | Page background. |
| `--color-surface` | `#ebe8df` | `#171c35` | Raised ground: code blocks, inline code. |
| `--color-fg` | `#141826` | `#eef0f7` | Body text. |
| `--color-muted` | `#5a5f73` | `#a2a8c2` | Secondary text: metadata, nav, footer. |
| `--color-border` | `#d5d2c7` | `#2b3152` | Hairline rules and control borders. |
| `--color-accent` | `#d7431b` | `#ff7a4d` | Links and interactive accents. |
| `--color-accent-strong` | `#b13413` | `#ffa07f` | Hover/active accent. |
| `--color-selection` | `#ffd9cc` | `#4a2b1f` | Text selection ground. |

#### Syntax highlighting

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--syn-keyword` | `#d7431b` | `#ff7a4d` | Syntax: keywords. |
| `--syn-string` | `#1f6f3a` | `#74d99a` | Syntax: strings and characters. |
| `--syn-comment` | `#7e8294` | `#7a80a0` | Syntax: comments (italic). |
| `--syn-function` | `#3c47b8` | `#a3acff` | Syntax: functions and methods. |
| `--syn-constant` | `#9a4f00` | `#ffc36b` | Syntax: constants, numbers, booleans. |
| `--syn-type` | `#1d6f8c` | `#6fd0ee` | Syntax: types, modules, tags, attributes. |
| `--syn-variable` | `#141826` | `#eef0f7` | Syntax: variables and default code text. |
| `--syn-punct` | `#5a5f73` | `#a2a8c2` | Syntax: punctuation and operators. |

#### Type and measure

| Token | Default | Role |
| --- | --- | --- |
| `--font-prose` | `'Anybody', system-ui, 'Segoe UI', Roboto, sans-serif` | The one face (Anybody, variable width and weight, self-hosted 50 KB latin subset, OFL). |
| `--font-mono` | `ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace` | Structure and code face. |
| `--measure` | `40rem` | Reading column width. |

### Templates

bellows ships 1 of the 9 templates in the contract; the rest resolve to the default theme's copy, so they stay current without you owning them. Overlay or eject any name in either list.

#### Shipped by bellows

| Template | Assigns | Purpose |
| --- | --- | --- |
| `page` | `@site`, `@doc` | A freeform page from the pages collection. |

#### Inherited from default

| Template | Assigns | Purpose |
| --- | --- | --- |
| `layout` | `@site`, `@inner`, `@page_title`, `@head_extra`, `@nav`, `@search`, `@page_class` | Outer HTML shell wrapped around every rendered page. |
| `post` | `@site`, `@doc` | A single blog post with title, date, and tags. |
| `post_list` | `@site`, `@posts` | Reverse-chronological index of published posts. |
| `tag` | `@site`, `@tag`, `@posts`, `@story_href` | Published posts carrying one tag; links to the tag's story when one exists. |
| `portfolio_timeline` | `@site`, `@portfolio`, `@cv_href` | The timeline mode of the profile: dated entries, open source; cv_href links the switcher back to the CV view when public. |
| `story` | `@site`, `@tag`, `@portfolio`, `@posts` | One tag across the whole story: portfolio entries plus blog posts. |
| `cv` | `@site`, `@cv` | The employer-shaped CV: cv-curated entries in the careers layout, print-first. |
| `not_found` | `@site` | The 404 page. |

### Working with an agent

Cherry ships [a skill](https://github.com/holsee/cherry/tree/develop/skills/cherry) that teaches a coding agent the operating loop above - the ladder, the CLI verbs, and the recovery playbook - so you can say *"make the accent electric blue, the Cherry way"* and it will reach for `cherry config tokens.--color-accent` instead of forking the stylesheet. Install it into your site's `.claude/skills/` (sites scaffolded with `cherry new` already carry `AGENTS.md` describing the same loop), then ask in terms of outcomes:

- *"Warm up bellows's palette for both renditions"* - the agent lists the manifest with `cherry theme.tokens`, overrides rung-1 tokens, and verifies with `cherry check`.
- *"Tighten the reading column"* - one token: `--measure`.
- *"Restyle the post list"* - rung 2 in `assets/custom.css` if CSS reaches it, `cherry theme.eject post_list` if structure has to change.

The one rule to hold an agent to: never edit the theme's own files under `themes/bellows/` unless they were ejected there on purpose - `cherry theme.diff` will name anything that drifts.
