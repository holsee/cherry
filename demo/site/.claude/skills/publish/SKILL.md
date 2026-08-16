---
name: publish
description: Draft, verify, and publish a blog post on this Cherry site
---

Publish a post end to end:

1. `mix cherry.gen.post "TITLE" --json` — note the returned path.
2. Write the post body; fill `description:` in the frontmatter.
3. `mix cherry.check --strict --json` — fix every diagnostic until
   the run is clean.
4. `mix cherry.publish PATH --json` — the draft becomes a dated post.
5. `mix cherry.build` and confirm the new page exists under `_site/`.
6. Commit the new post file (never `_site/`).
