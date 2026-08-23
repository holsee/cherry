---
title: "Using cherrybomb"
description: "Install, override, and extend the cherrybomb theme the Cherry way: its token API, its templates, and where each rung of the styling ladder applies."
---
## Using cherrybomb

The brand theme — neon night wall by dark, poster paper by day.

See it live in the [exhibition](https://cherrybomb.dev/t/cherrybomb/), or back in [the gallery](/themes/). Like every official theme, cherrybomb implements theme contract 1.0: every colour flows through the tokens below, the stylesheet lives in the `theme` cascade layer so your unlayered overrides always win, and any template it does not ship falls back to the default theme's copy.

### Install

One config line, or one command:

```elixir
# cherry.exs
theme: "cherrybomb"
```

```text
$ cherry config theme cherrybomb
```

Then `cherry build` (or `cherry serve` while you look around). Nothing else moves: your content, your overlays for other themes, and your token overrides for other themes stay where they are.

### The styling ladder, applied to cherrybomb

Restyling costs exactly as much ownership as you choose to take. In order:

**Rung 1 - override a token.** The manifest below is cherrybomb's public styling API. Overrides land in every page head, survive theme upgrades, and are validated against the manifest (a typo is an error, not a dead line):

```text
$ cherry config tokens.--color-accent "light-dark(#c0134f, #ff4d7d)"
$ cherry theme.tokens        # shows the merged view
```

**Rung 2 - custom.css.** Drop `assets/custom.css` into your site and it links after the theme stylesheet and the tokens block on every page. cherrybomb's own CSS lives in the `theme` cascade layer, so a plain selector in your unlayered file beats the theme without specificity games or `!important`.

**Rung 3 - overlay a template.** Write `themes/cherrybomb/templates/<template>.html.eex` (or `.html.heex`) in your site and it shadows just that template.

**Rung 4 - eject.** `cherry theme.eject <template>` copies the original into that overlay directory with a provenance header, so `cherry theme.diff` can tell you forever after whether upstream moved under your copy.

**Rung 5 - a theme of your own.** `cherry gen.theme mytheme --from cherrybomb` scaffolds the whole thing - manifest, templates, stylesheet - into `themes/mytheme/`, yours deliberately.

The [theming reference](/docs/theming/) covers every rung in depth; the [theme guide](/guides/creating-a-theme/) walks rung 5.

### Token API

Colour tokens are `light-dark()` pairs: one override sets both renditions, and the theme toggle flips a single `color-scheme` property.

#### Surface and text

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--color-bg` | `#fbf6f8` | `#14090f` | Page background (poster paper by day, the wall at night). |
| `--color-surface` | `#f3e7ed` | `#1f1016` | Raised ground: code blocks, inline code. |
| `--color-fg` | `#26141d` | `#f5e7ee` | Body text. |
| `--color-muted` | `#6d5563` | `#b39aa8` | Secondary text: metadata, nav, footer. |
| `--color-border` | `#e6d2dc` | `#3a2230` | Hairline rules and control borders. |
| `--color-accent` | `#c0134f` | `#ff4d7d` | The hot pink: links, title stroke, glow. |
| `--color-accent-strong` | `#96063c` | `#ff7a9e` | Hover/active accent. |
| `--color-selection` | `#ffd3e0` | `#5c1030` | Text selection ground. |

#### Syntax highlighting

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--syn-keyword` | `#c0134f` | `#ff4d7d` | Syntax: keywords. |
| `--syn-string` | `#0b7a5e` | `#45e0b8` | Syntax: strings and characters. |
| `--syn-comment` | `#75616d` | `#9a8292` | Syntax: comments (italic). |
| `--syn-function` | `#6d3ac1` | `#c89bff` | Syntax: functions and methods. |
| `--syn-constant` | `#a55a00` | `#ffb454` | Syntax: constants, numbers, booleans. |
| `--syn-type` | `#0369a1` | `#56d8ff` | Syntax: types, modules, tags, attributes. |
| `--syn-variable` | `#26141d` | `#f5e7ee` | Syntax: variables and default code text. |
| `--syn-punct` | `#6d5563` | `#b39aa8` | Syntax: punctuation and operators. |

#### Type and measure

| Token | Default | Role |
| --- | --- | --- |
| `--font-prose` | `system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif` | Reading face: the wall speaks sans (system stack, zero bytes). |
| `--font-mono` | `'Noto Sans Mono', ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace` | Structure and code face. Noto Sans Mono ships with the theme (latin subset, self-hosted, 32 KB); everything after it is the fallback stack. |
| `--measure` | `42rem` | Reading column width (~66ch). |

### Templates

cherrybomb ships every one of the 9 templates in the contract; nothing falls back. Overlay or eject any name in either list.

#### Shipped by cherrybomb

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

#### Inherited from default

_None - every template is the theme's own._

### Working with an agent

Cherry ships [a skill](https://github.com/holsee/cherry/tree/develop/skills/cherry) that teaches a coding agent the operating loop above - the ladder, the CLI verbs, and the recovery playbook - so you can say *"make the accent electric blue, the Cherry way"* and it will reach for `cherry config tokens.--color-accent` instead of forking the stylesheet. Install it into your site's `.claude/skills/` (sites scaffolded with `cherry new` already carry `AGENTS.md` describing the same loop), then ask in terms of outcomes:

- *"Warm up cherrybomb's palette for both renditions"* - the agent lists the manifest with `cherry theme.tokens`, overrides rung-1 tokens, and verifies with `cherry check`.
- *"Tighten the reading column"* - one token: `--measure`.
- *"Restyle the post list"* - rung 2 in `assets/custom.css` if CSS reaches it, `cherry theme.eject post_list` if structure has to change.

The one rule to hold an agent to: never edit the theme's own files under `themes/cherrybomb/` unless they were ejected there on purpose - `cherry theme.diff` will name anything that drifts.
