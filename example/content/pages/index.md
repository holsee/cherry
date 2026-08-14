---
title: Home
---
# Cherrybomb

**Cherry** is a static site generator built in Elixir — the spiritual
successor to Octopress, designed from day one for both humans and their
agents.

- **Typed content.** Collections carry introspectable schemas; broken
  frontmatter fails the build with the file and field named.
- **Deterministic builds.** Same input, same bytes — time is an input,
  never a clock read.
- **Default-on SEO.** Canonical URLs, Open Graph, JSON-LD, Atom feed,
  sitemap, robots — no plugins, no config.
- **Themes with a contract.** Swap themes without touching content;
  eject a template with provenance when you need to own it.

## The loop

```
mix cherry.gen.post "Growing season"
mix cherry.serve
mix cherry.publish content/posts/*growing-season.md
mix cherry.build
```

Read the [blog](/blog/) for progress notes, or the
[about page](/about/) for where this is heading.
