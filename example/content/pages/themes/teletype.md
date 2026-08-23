---
title: "Using teletype"
description: "Install, override, and extend the teletype theme the Cherry way: its token API, its templates, and where each rung of the styling ladder applies."
---
## Using teletype

All-mono devlog: paper printout by day, amber-phosphor terminal by night.

<figure class="theme-hero">
<picture><source srcset="/images/themes/teletype-dark.png" media="(prefers-color-scheme: dark)"><img src="/images/themes/teletype-light.png" alt="The teletype theme home page" width="1200" height="750"></picture>
<p class="theme-hero-actions"><a class="button" href="/t/teletype/">Live demo</a></p>
</figure>

Like every official theme in [the gallery](/themes/), teletype implements theme contract 1.1: every colour flows through the tokens below, the stylesheet lives in the `theme` cascade layer so your unlayered overrides always win, and any template it does not ship falls back to the default theme's copy.

### Install

One config line, or one command:

```elixir
# cherry.exs
theme: "teletype"
```

```text
$ cherry config theme teletype
```

Then `cherry build` (or `cherry serve` while you look around). Nothing else moves: your content, your overlays for other themes, and your token overrides for other themes stay where they are.

### The styling ladder, applied to teletype

Restyling costs exactly as much ownership as you choose to take. In order:

**Rung 1 - override a token.** The manifest below is teletype's public styling API. Overrides land in every page head, survive theme upgrades, and are validated against the manifest (a typo is an error, not a dead line):

```text
$ cherry config tokens.--color-accent "light-dark(#9a6700, #e3b341)"
$ cherry theme.tokens        # shows the merged view
```

**Rung 2 - custom.css.** Drop `assets/custom.css` into your site and it links after the theme stylesheet and the tokens block on every page. teletype's own CSS lives in the `theme` cascade layer, so a plain selector in your unlayered file beats the theme without specificity games or `!important`.

**Rung 3 - overlay a template.** Write `themes/teletype/templates/<template>.html.eex` (or `.html.heex`) in your site and it shadows just that template.

**Rung 4 - eject.** `cherry theme.eject <template>` copies the original into that overlay directory with a provenance header, so `cherry theme.diff` can tell you forever after whether upstream moved under your copy.

**Rung 5 - a theme of your own.** `cherry gen.theme mytheme --from teletype` scaffolds the whole thing - manifest, templates, stylesheet - into `themes/mytheme/`, yours deliberately.

The [theming reference](/docs/theming/) covers every rung in depth; the [theme guide](/guides/creating-a-theme/) walks rung 5.

### Token API

Colour tokens are `light-dark()` pairs: one override sets both renditions, and the theme toggle flips a single `color-scheme` property.

#### Surface and text

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--color-bg` | `#fafaf7` | `#0f1210` | Page background. |
| `--color-surface` | `#f0f0ea` | `#171b18` | Raised ground: code blocks, inline code. |
| `--color-fg` | `#30353a` | `#c9d1c9` | Body text. |
| `--color-muted` | `#676f77` | `#8b9a8b` | Secondary text: metadata, nav, footer. |
| `--color-border` | `#e0e2dc` | `#263029` | Hairline rules and control borders. |
| `--color-accent` | `#9a6700` | `#e3b341` | Links and interactive accents. |
| `--color-accent-strong` | `#7a5200` | `#f0ca6a` | Hover/active accent. |
| `--color-selection` | `#fff0c2` | `#4a3a10` | Text selection ground. |

#### Syntax highlighting

| Token | Light | Dark | Role |
| --- | --- | --- | --- |
| `--syn-keyword` | `#9a6700` | `#e3b341` | Syntax: keywords. |
| `--syn-string` | `#116329` | `#7ce38b` | Syntax: strings and characters. |
| `--syn-comment` | `#6e7781` | `#768390` | Syntax: comments (italic). |
| `--syn-function` | `#0b6bcb` | `#6cb6ff` | Syntax: functions and methods. |
| `--syn-constant` | `#8250df` | `#c8a1ff` | Syntax: constants, numbers, booleans. |
| `--syn-type` | `#0e7490` | `#76c7da` | Syntax: types, modules, tags, attributes. |
| `--syn-variable` | `#30353a` | `#c9d1c9` | Syntax: variables and default code text. |
| `--syn-punct` | `#676f77` | `#8b9a8b` | Syntax: punctuation and operators. |

#### Type and measure

| Token | Default | Role |
| --- | --- | --- |
| `--font-prose` | `'Noto Sans Mono', ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace` | Reading face — the same mono as everything else (Noto Sans Mono, self-hosted 32 KB latin subset, OFL). |
| `--font-mono` | `'Noto Sans Mono', ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace` | Structure and code face — identical to --font-prose by design. |
| `--measure` | `40rem` | Reading column width (~72ch of mono). |

### Templates

teletype ships no templates of its own: all 9 in the contract resolve to the default theme's copy, so its whole voice is CSS and every template stays current without you owning it. Overlay or eject any name in either list.

#### Shipped by teletype

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

- *"Warm up teletype's palette for both renditions"* - the agent lists the manifest with `cherry theme.tokens`, overrides rung-1 tokens, and verifies with `cherry check`.
- *"Tighten the reading column"* - one token: `--measure`.
- *"Restyle the post list"* - rung 2 in `assets/custom.css` if CSS reaches it, `cherry theme.eject post_list` if structure has to change.

The one rule to hold an agent to: never edit the theme's own files under `themes/teletype/` unless they were ejected there on purpose - `cherry theme.diff` will name anything that drifts.
