---
title: Cherry and NimblePublisher
description: They both turn markdown into websites, and they are barely the same species. When a compile-time content library is the right call, when a static site generator is, and where the line sits.
tags:
  - elixir
  - design
---
"Should I use Cherry or NimblePublisher?" is a reasonable question with a
slightly unreasonable premise, because they are barely the same species.
[NimblePublisher](https://github.com/dashbitco/nimble_publisher) is a small,
sharp library that turns markdown files into in-memory Elixir structs at
compile time. Cherry is a static site generator that emits a deployable
tree of files. One gives you data, the other gives you a website. This post
draws the line properly, because on the right side of it each tool is
clearly the better choice.

## What NimblePublisher is

NimblePublisher, from Dashbit, is about a hundred lines of very good taste.
You point it at a glob of markdown files, each opening with an Elixir map
literal as frontmatter, and at compile time it parses them and hands your
module the result:

```elixir
use NimblePublisher,
  build: Post,
  from: "posts/**/*.md",
  as: :posts
```

After that, `@posts` is a list of `%Post{}` structs, inside your
application, with zero runtime cost. Everything else is yours to build:
routing, layouts, RSS, SEO tags, search, deployment. In practice that
means it lives inside a Phoenix application that already exists, where
posts become one more data source your controllers and LiveViews render
like anything else.

That design has real virtues. There is no second artifact to deploy: the
blog ships inside the app you were already shipping. Content sits next to
code in the same repository and the same review flow. And because posts
are just structs, anything dynamic is trivial, from related-post queries
to rendering inside a LiveView.

## What Cherry is

Cherry starts where NimblePublisher stops, because the pipeline is the
product. Typed frontmatter where an unknown field is a build error with a
file and line, not a silent nil. Themes with tokens as the styling API,
overlays that carry provenance, and upgrades that merge instead of
freezing. Search without Node, feeds, sitemaps, and the machine surface
(`llms.txt`, markdown mirrors of every page) generated from the same
content pass as the HTML so nothing can drift. A verifier that returns
structured diagnostics. Deterministic builds, gated in CI. And the output
is a `_site/` directory any static host serves, deployed by the workflow
`cherry gen.action` writes for you.

The deeper difference is who can operate it. NimblePublisher assumes an
Elixir developer with a compiler at hand, because publishing means
recompiling an application. Cherry ships as a standalone binary with a
CLI, so the loop runs without Elixir installed, and every verb takes
`--json`:

```text
$ cherry version
cherry 0.3.0 (cb4bad2)
```

That is what makes the whole site operable by an agent as well as a
human, which is a design goal here, not a side effect.

## The comparison, honestly

|  | NimblePublisher | Cherry |
|---|---|---|
| What it is | Compile-time content library | Static site generator and CLI |
| Output | Elixir structs in your app | A `_site/` static tree |
| Needs your own app | Yes, in practice | No |
| Layouts, feeds, SEO, search | You write them | Built in, themed |
| Content validation | Whatever you code | Schema-enforced diagnostics |
| Publishing | Redeploy the application | Rebuild, push static files |
| Non-Elixir operators, agents | No | Binary plus `--json` envelopes |

Could you build a Cherry-shaped tool on top of NimblePublisher as the
parsing layer? Roughly, yes. Cherry owns its pipeline instead, and the
reason is the compile-time embedding itself: it is NimblePublisher's
defining feature and exactly what a static site generator does not want.
Content changes should not mean recompiling an application, and a binary
user has no compiler at all.

## Which one you want

If you already run a Phoenix application and want five posts living
inside it, use NimblePublisher. It is lighter, the posts deploy with the
app, and anything dynamic comes free. Reaching for a whole site generator
there would be carrying a second artifact for no reason.

Cherry earns its keep when the site is the product: a blog, a portfolio,
documentation, anything that should be standalone, themed, verified,
served from a CDN, and runnable end to end by someone (or something) that
never opens an editor. This site is the standing example, and every page
of it is also [plain markdown](/index.md), which is the kind of thing you
get to promise when the generator owns the whole pipeline.

Two good tools. The line between them is just the question "is the site
inside your app, or is the site the app?"
