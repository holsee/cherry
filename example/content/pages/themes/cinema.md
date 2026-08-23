---
title: "Using cinema"
description: "Install, override, and extend the cinema theme the Cherry way: its token API, its templates, and where each rung of the styling ladder applies."
---
## Using cinema

A film opening: a looping video background under the home title, a transparent mast, Big Shoulders Display over Manrope.

<figure class="theme-hero">
<picture><source srcset="/images/themes/cinema-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/cinema-light.png" alt="The cinema theme home page" width="1200" height="750"></picture>
<p class="theme-hero-actions"><a class="button" href="/t/cinema/">Live demo</a></p>
</figure>

Like every official theme in [the gallery](/themes/), cinema implements theme contract 1.1: every colour flows through the tokens below, the stylesheet lives in the `theme` cascade layer so your unlayered overrides always win, and any template it does not ship falls back to the default theme's copy.

### Install

One config line, or one command:

```elixir
# cherry.exs
theme: "cinema"
```

```text
$ cherry config theme cinema
```

Then `cherry build` (or `cherry serve` while you look around). Nothing else moves: your content, your overlays for other themes, and your token overrides for other themes stay where they are.

### The styling ladder, applied to cinema

Restyling costs exactly as much ownership as you choose to take. In order:

**Rung 1 - override a token.** The manifest below is cinema's public styling API. Overrides land in every page head, survive theme upgrades, and are validated against the manifest (a typo is an error, not a dead line):

```text
$ cherry config tokens.--color-accent "light-dark(#c8102e, #ff3b4e)"
$ cherry theme.tokens        # shows the merged view
```

**Rung 2 - custom.css.** Drop `assets/custom.css` into your site and it links after the theme stylesheet and the tokens block on every page. cinema's own CSS lives in the `theme` cascade layer, so a plain selector in your unlayered file beats the theme without specificity games or `!important`.

**Rung 3 - overlay a template.** Write `themes/cinema/templates/<template>.html.eex` (or `.html.heex`) in your site and it shadows just that template.

**Rung 4 - eject.** `cherry theme.eject <template>` copies the original into that overlay directory with a provenance header, so `cherry theme.diff` can tell you forever after whether upstream moved under your copy.

**Rung 5 - a theme of your own.** `cherry gen.theme mytheme --from cinema` scaffolds the whole thing - manifest, templates, stylesheet, islands - into `themes/mytheme/`, yours deliberately.

The [theming reference](/docs/theming/) covers every rung in depth; the [theme guide](/guides/creating-a-theme/) walks rung 5.

### Token API

Colour tokens are `light-dark()` pairs: one override sets both renditions, and the theme toggle flips a single `color-scheme` property.

#### Surface and text

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--color-bg` | `#f2f2f2` | `#0a0a0a` | Page background. |
| `--color-surface` | `#e8e8e8` | `#161616` | Raised ground: code blocks, inline code. |
| `--color-fg` | `#111111` | `#f0f0f0` | Body text. |
| `--color-muted` | `#5a5a5a` | `#9a9a9a` | Secondary text: metadata, nav, footer. |
| `--color-border` | `#d8d8d8` | `#262626` | Hairline rules and control borders. |
| `--color-accent` | `#c8102e` | `#ff3b4e` | Links and interactive accents. |
| `--color-accent-strong` | `#960b22` | `#ff7a87` | Hover/active accent. |
| `--color-selection` | `#ffd6dc` | `#4a1219` | Text selection ground. |

#### Syntax highlighting

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--syn-keyword` | `#c8102e` | `#ff3b4e` | Syntax: keywords. |
| `--syn-string` | `#1f6f4a` | `#7fd9a8` | Syntax: strings and characters. |
| `--syn-comment` | `#808080` | `#7a7a7a` | Syntax: comments (italic). |
| `--syn-function` | `#6a2fb8` | `#c9a6ff` | Syntax: functions and methods. |
| `--syn-constant` | `#1a55b8` | `#8db8ff` | Syntax: constants, numbers, booleans. |
| `--syn-type` | `#a05a00` | `#ffb06a` | Syntax: types, modules, tags, attributes. |
| `--syn-variable` | `#111111` | `#f0f0f0` | Syntax: variables and default code text. |
| `--syn-punct` | `#5a5a5a` | `#9a9a9a` | Syntax: punctuation and operators. |

#### Type and measure

| Token | Default | Role |
| --- | --- | --- |
| `--font-prose` | `'Manrope', system-ui, 'Segoe UI', Roboto, sans-serif` | Reading face (Manrope, self-hosted 21 KB latin subset, OFL). Titles use Big Shoulders Display (24 KB). |
| `--font-mono` | `ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace` | Structure and code face. |
| `--measure` | `44rem` | Reading column width. |

### Templates

cinema ships 2 of the 9 templates in the contract; the rest resolve to the default theme's copy, so they stay current without you owning them. Overlay or eject any name in either list.

#### Shipped by cinema

| Template | Assigns | Purpose |
| --- | --- | --- |
| `layout` | `@site`, `@inner`, `@page_title`, `@head_extra`, `@nav`, `@search`, `@page_class` | Outer HTML shell wrapped around every rendered page. |
| `page` | `@site`, `@doc` | A freeform page from the pages collection. |

#### Inherited from default

| Template | Assigns | Purpose |
| --- | --- | --- |
| `post` | `@site`, `@doc` | A single blog post with title, date, and tags. |
| `post_list` | `@site`, `@posts` | Reverse-chronological index of published posts. |
| `tag` | `@site`, `@tag`, `@posts`, `@story_href` | Published posts carrying one tag; links to the tag's story when one exists. |
| `portfolio_timeline` | `@site`, `@portfolio`, `@cv_href` | The timeline mode of the profile: dated entries, open source; cv_href links the switcher back to the CV view when public. |
| `story` | `@site`, `@tag`, `@portfolio`, `@posts` | One tag across the whole story: portfolio entries plus blog posts. |
| `cv` | `@site`, `@cv` | The employer-shaped CV: cv-curated entries in the careers layout, print-first. |
| `not_found` | `@site` | The 404 page. |

### Working with an agent

Cherry ships [a skill](https://github.com/holsee/cherry/tree/develop/skills/cherry) that teaches a coding agent the operating loop above - the ladder, the CLI verbs, and the recovery playbook - so you can say *"make the accent electric blue, the Cherry way"* and it will reach for `cherry config tokens.--color-accent` instead of forking the stylesheet. Install it into your site's `.claude/skills/` (sites scaffolded with `cherry new` already carry `AGENTS.md` describing the same loop), then ask in terms of outcomes:

- *"Warm up cinema's palette for both renditions"* - the agent lists the manifest with `cherry theme.tokens`, overrides rung-1 tokens, and verifies with `cherry check`.
- *"Tighten the reading column"* - one token: `--measure`.
- *"Restyle the post list"* - rung 2 in `assets/custom.css` if CSS reaches it, `cherry theme.eject post_list` if structure has to change.

The one rule to hold an agent to: never edit the theme's own files under `themes/cinema/` unless they were ejected there on purpose - `cherry theme.diff` will name anything that drifts.
