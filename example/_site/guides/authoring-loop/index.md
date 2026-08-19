# The authoring loop

# The authoring loop

Writing on a Cherry site is four verbs. Here's the whole loop with real output.

## Scaffold a draft

```sh
cherry gen.post "Growing season" --json
```

```json
{
  "ok": true,
  "command": "gen.post",
  "data": {
    "date": "2026-08-10",
    "path": "content/posts/2026-08-10-growing-season.md",
    "slug": "growing-season"
  }
}
```

The file lands with valid frontmatter and `draft: true`:

```markdown
---
title: Growing season
date: 2026-08-10
tags: []
draft: true
description:
---
```

> [!NOTE]
> `data.path` is source-relative. Every later command that takes a path, `publish` included, wants it exactly in that form, so you can pipe one envelope straight into the next command untouched.

## Write with the server running

```sh
cherry serve
```

Drafts are included in serve mode and every save reloads the browser. Real builds (`cherry build`) exclude drafts unless you pass `--drafts`; future-dated posts stay hidden unless you pass `--future`.

## Publish

Publishing flips the draft flag off and re-dates the post to today. Filename, frontmatter, and URL all move together:

```sh
cherry publish content/posts/2026-08-10-growing-season.md --json
```

```json
{
  "ok": true,
  "command": "publish",
  "data": {
    "date": "2026-08-14",
    "from": "content/posts/2026-08-10-growing-season.md",
    "to": "content/posts/2026-08-14-growing-season.md"
  }
}
```

> [!WARNING]
> The file moved: anything referencing `from` needs updating to `to`. If a script drives this step, capture both.

## What a post becomes

One markdown file fans out into the built site as:

- `growing-season/index.html`: the themed page
- `growing-season/index.md`: a markdown mirror of the same content, curl-able with no theme wrapping
- an entry in `feed.xml`, `feed.json`, `sitemap.xml`, and the blog index
- a tag page per tag, with JSON-LD structured data in the post's head

Nothing on that list is opt-in. Check the [verifier guide](/guides/check/) for keeping it all honest.
