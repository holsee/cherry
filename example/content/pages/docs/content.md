---
title: The content model
description: Collections, frontmatter schemas, drafts, the publish flow, and the portfolio.
---
## The content model

Everything you write lives under `content/`, in typed collections. Typed means each collection publishes a schema, the build validates every file against it, and an unknown key is an error naming the file, not a silently ignored line. Ask the CLI, never guess:

```text
$ cherry schema posts
posts frontmatter:
  title: string (required) — Post title.
  date: date — ISO 8601 date; defaults to the date in the filename.
  slug: string — URL slug; defaults to the filename after the date.
  tags: list of string [default: []] — Tags from the shared site taxonomy (also used by the portfolio).
  draft: boolean [default: false] — Drafts are skipped unless `--drafts`.
  description: string — Meta description for SEO and feeds.
```

### Posts

`content/posts/YYYY-MM-DD-slug.md`. The filename is the source of truth for the date and slug; frontmatter can override the slug. A post renders at `/slug/`, joins the blog index, its tags' pages, and both feeds.

The draft flow is built in. `cherry gen.post "Title"` scaffolds with `draft: true`; drafts appear in `cherry serve` (your writing loop) but never in `cherry build` unless you pass `--drafts`. When it is ready:

```text
$ cherry publish my-draft
```

renames the file to today's date and removes the `draft:` line. Nothing else changes.

### Pages

`content/pages/*.md`, freeform. `about.md` becomes `/about/`; nested directories nest the URL. A `permalink:` overrides the derived route, which is how a section index gets a clean URL:

```yaml
---
title: Docs
permalink: /docs/
---
```

### The portfolio

Five more collections carry your developer story, each a directory of markdown files under `content/portfolio/`: `positions`, `projects`, `talks`, `oss`, and `education`. A `portfolio.yaml` at the site root holds the profile (name, headline, location, links). A position looks like this:

```yaml
---
title: Staff Engineer
org: Orchard Systems
start: 2020-02-01
location: Remote
tags:
  - elixir
highlights:
  - Grew the platform from seed to fruit
cv:
  include: true
  weight: 10
---
The long-form story, in markdown, for the portfolio page.
```

Those collections render three surfaces for free:

- **`/cv/`**: the employer-shaped page, and the profile's default mode. The `cv:` block is the curation layer: `include` opts an entry in, `weight` orders it, and an optional `cv.highlights` list overrides the bullets with a tighter cut. Print it and the stylesheet produces a clean one-pager; `cv.json` ships beside it in JSON Resume format.
- **`/cv/timeline/`**: the alternate mode, a dated timeline of everything with the profile header. A view switcher links the two.
- **Story pages** at `/story/TAG/`: everything sharing a tag, portfolio entries and blog posts together. Tags are one taxonomy across the whole site.

The [portfolio guide](/guides/portfolio-and-cv/) builds all of this from scratch.

### Markdown

GitHub-flavoured throughout: tables, strikethrough, task lists, footnotes, autolinks. Heading anchors are automatic. Syntax highlighting is class-based and coloured by [theme tokens](/docs/theming/), so code blocks follow your palette in both renditions.

Fenced code blocks grow a header bar when the fence names a language: the language in small text with its editor-style file icon (the same glyph set file trees use, shipped in the official themes as `currentColor` masks - no requests, no colour clashes). Add `title="…"` to the fence and the header carries the file path too; both parts are optional, and a bare fence stays a bare block:

````markdown
```elixir title="lib/press/scheduler.ex"
def press(crates), do: Enum.each(crates, &Press.run/1)
```
````

The copy button rides the header bar when one exists, so it never covers code. GitHub-style alerts work as blockquotes (`> [!NOTE]`), and the richer [content components](/docs/components/) cover figures, video, and callouts. Raw HTML passes through, which is how this site's landing page is built.

:::tip{title="Let the generators write the boilerplate"}
`cherry gen.post`, `gen.project`, and `gen.talk` all emit files that satisfy their schemas, with a `--json` envelope carrying the path. The verifier's `unfilled-field` rule then reminds you about any scaffold string you forgot to replace.
:::
