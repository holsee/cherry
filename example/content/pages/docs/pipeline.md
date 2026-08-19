---
title: The build pipeline
description: The nine stages between your markdown and _site/, and why builds are byte-deterministic.
---
## The build pipeline

A build is a token passed through nine ordered stages. Each stage either enriches the build or halts it with a diagnostic naming the file at fault; there is no partial output. The whole thing is one Elixir pipeline, and [you can drive it programmatically](/cherry-from-elixir/) if the CLI is not enough.

<div class="diagram" role="img" aria-label="The nine pipeline stages: Load, Validate, Transform, Layout, Feeds, then Machine, Search, Emit, Post.">
<svg viewBox="0 0 720 200" xmlns="http://www.w3.org/2000/svg" style="font-family: var(--font-mono); font-size: 14px;">
  <g fill="var(--color-surface)" stroke="var(--color-border)">
    <rect x="10"  y="24" width="116" height="44" rx="8"/>
    <rect x="152" y="24" width="116" height="44" rx="8"/>
    <rect x="294" y="24" width="116" height="44" rx="8"/>
    <rect x="436" y="24" width="116" height="44" rx="8"/>
    <rect x="578" y="24" width="116" height="44" rx="8"/>
    <rect x="578" y="132" width="116" height="44" rx="8"/>
    <rect x="436" y="132" width="116" height="44" rx="8"/>
    <rect x="294" y="132" width="116" height="44" rx="8" stroke="var(--color-accent)"/>
    <rect x="152" y="132" width="116" height="44" rx="8"/>
  </g>
  <g fill="var(--color-fg)" text-anchor="middle">
    <text x="68"  y="51">Load</text>
    <text x="210" y="51">Validate</text>
    <text x="352" y="51">Transform</text>
    <text x="494" y="51">Layout</text>
    <text x="636" y="51">Feeds</text>
    <text x="636" y="159">Machine</text>
    <text x="494" y="159">Search</text>
    <text x="352" y="159" fill="var(--color-accent)">Emit</text>
    <text x="210" y="159">Post</text>
  </g>
  <g stroke="var(--color-muted)" fill="var(--color-muted)">
    <line x1="126" y1="46" x2="146" y2="46"/><polygon points="146,42 152,46 146,50"/>
    <line x1="268" y1="46" x2="288" y2="46"/><polygon points="288,42 294,46 288,50"/>
    <line x1="410" y1="46" x2="430" y2="46"/><polygon points="430,42 436,46 430,50"/>
    <line x1="552" y1="46" x2="572" y2="46"/><polygon points="572,42 578,46 572,50"/>
    <line x1="636" y1="68" x2="636" y2="126"/><polygon points="632,126 636,132 640,126"/>
    <line x1="578" y1="154" x2="558" y2="154"/><polygon points="558,150 552,154 558,158"/>
    <line x1="436" y1="154" x2="416" y2="154"/><polygon points="416,150 410,154 416,158"/>
    <line x1="294" y1="154" x2="274" y2="154"/><polygon points="274,150 268,154 274,158"/>
  </g>
  <g fill="var(--color-muted)" font-size="11px" text-anchor="middle">
    <text x="352" y="16">halts with a diagnostic, or continues</text>
    <text x="352" y="196">Emit is the only stage that writes to disk</text>
  </g>
</svg>
</div>

### What each stage does

| stage | responsibility |
|---|---|
| `Load` | Reads `cherry.exs`, content collections, portfolio, CV, and static files into one in-memory site. |
| `Validate` | Frontmatter against [the schemas](/docs/content/), date sanity, duplicate slugs, token overrides against the theme manifest. Fails loud, names the file. |
| `Transform` | [Content components](/docs/components/) expand first, then markdown becomes HTML: tables, footnotes, autolinks, and class-based syntax highlighting colored by theme tokens. |
| `Layout` | Resolves [the theme chain](/docs/theming/), renders every page through its template (EEx or HEEx), injects the SEO head, token overrides, and `custom.css`. |
| `Feeds` | `feed.xml` (Atom), `feed.json`, `sitemap.xml`, canonical URLs, all derived from your configured `url`. |
| `Machine` | `llms.txt` plus a markdown mirror beside every page: [the machine surface](/docs/machine-surface/). |
| `Search` | Builds the search index. `search: "cherry"` needs no Node anywhere; `"pagefind"` shells out after Emit instead. |
| `Emit` | Writes the tree. The only stage that touches disk. |
| `Post` | Post-emit hooks: Pagefind indexing, anything that needs the finished tree. |

### Determinism is a gate, not a goal

The same input tree produces the same output bytes, every time, on every platform. Cherry's own CI double-builds its fixture sites and the demo on every commit and fails if a single byte differs. What that buys you:

- **Diffs mean something.** If the deployed tree changed, you changed it.
- **Caches work.** Unchanged pages hash identically across builds.
- **CI can prove drift.** Build twice in your own pipeline and compare; a mismatch is a bug in Cherry, and we treat it as one.

:::note{title="Where the randomness went"}
No timestamps in output, no build IDs, no "generated at" footers, stable ordering everywhere a map could have leaked iteration order. The discipline is invisible until you need it, and then it is everything.
:::
