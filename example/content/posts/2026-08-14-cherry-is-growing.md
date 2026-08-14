---
title: Cherry is growing
tags:
  - meta
description: The dogfood site goes live, built by Cherry on every CI run.
---
This site is built by Cherry itself: the `example/` directory in the
repository, compiled on every CI run so the framework can never drift
from its own instructions.

A Cherry site is a directory with a config and some markdown:

```elixir
# cherry.exs
[
  title: "Cherrybomb",
  url: "https://cherrybomb.dev",
  description: "Cherry is a static site generator for hackers."
]
```

Posts are files whose names carry their date and slug, with typed
frontmatter checked at build time:

```
content/posts/2026-08-14-cherry-is-growing.md
```

Everything else (feeds, sitemaps, canonical URLs, the theme) is
default-on. Delete this post and the site still validates; that is the
point.
