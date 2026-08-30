---
title: Configuration
description: cherry.exs key by key, and how cherry config edits it without an editor.
---
## Configuration

A Cherry site has exactly one configuration file: `cherry.exs` at the site root, a plain Elixir keyword list. This site's own file is a complete real example:

```elixir
[
  title: "CherryBomb",
  url: "https://cherrybomb.dev",
  description: "Cherry is a static site generator for hackers, a modern take on Octopress.",
  author: "holsee",
  theme: "cherrybomb",
  search: "cherry",
  social_image: "og-card.png",
  nav: [
    [label: "Guides", href: "guides/", position: :start],
    [label: "Docs", href: "docs/", position: :start]
  ]
]
```

The file is schema-validated at load: an unknown key or a bad value is a build error naming the key, never a silently ignored line.

### Every key

| key | type | what it does |
|---|---|---|
| `title` | string, required | The site name: header, feeds, page titles. |
| `url` | string, required | The real deployed URL. Canonical links, feeds, and the sitemap derive from it. |
| `description` | string | Site-level meta description and feed subtitle. |
| `author` | string | Feed author; defaults to the title. |
| `theme` | string | `"default"`, `"cherrybomb"`, or a site-local path like `"themes/neon"`. |
| `search` | string | `"cherry"` builds the index in-process with no Node anywhere; `"pagefind"` shells out to Pagefind at the end of the build. Unset means no search. |
| `base_path` | string | For project pages served under a subpath, e.g. `"/repo"`. Every link, image, feed URL, and component src is rewritten. |
| `social_image` | string | Site-relative fallback social card, e.g. `"og-card.png"`. Pages without their own image use it, and it upgrades the Twitter card to `summary_large_image`. |
| `analytics` | keyword list | One analytics provider, e.g. `[cloudflare: "token"]`. `cloudflare`, `plausible` and `goatcounter` are cookieless and ship no consent banner; `google` sets cookies, so it ships a consent gate and does not load until the visitor accepts. See the [analytics guide](/guides/analytics/). |
| `nav` | list | Extra nav entries; see below. |
| `tokens` | keyword list | Theme token overrides; see below. |

### Navigation

The built-in nav entries (Blog, then Portfolio and CV when those collections exist) come free. `nav:` adds yours:

```elixir
nav: [
  [label: "Guides", href: "guides/", position: :start],
  [label: "Sponsor", href: "https://github.com/sponsors/you"]
]
```

`position: :start` places an entry before the built-ins; the default `:end` appends after them. Site-relative hrefs pass through `base_path` rewriting; absolute `http(s)` hrefs are left alone. Nav hrefs are checked by the same broken-link rule as everything else, so a nav entry to a page you deleted fails `cherry check`.

### Theme tokens

`tokens:` overrides any token the active theme's manifest declares. This is rung one of [the styling ladder](/docs/theming/):

```elixir
tokens: [
  "--color-accent": "light-dark(#7c3aed, #a78bfa)"
]
```

A plain value applies to both renditions; a `light-dark(a, b)` pair carries both. A token the theme does not declare is a build error with a suggestion:

```text
error: tokens: --color-acent is not a token of theme default (did you mean --color-accent?) — `cherry theme.tokens` lists them
```

### Editing without an editor

Everything above can be read and written from the CLI, which is how agents (and scripts) configure a site:

```text
$ cherry config                       # everything, resolved
$ cherry config title                 # one value
$ cherry config title "Juno Vale"     # write one value
$ cherry config tokens.--color-accent "#7c3aed"
```

Writes are surgical: only the value changes, comments survive, and an invalid value is rolled back with the file left untouched. Structured keys (`nav:`) are refused rather than reformatted; edit those in the file. The full behaviour is documented in [the CLI reference](/docs/cli/).
