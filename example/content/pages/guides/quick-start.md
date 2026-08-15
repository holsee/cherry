---
title: Quick-start
description: Install Cherry, make a site, write a post, and deploy it to GitHub Pages. The whole path, with real output at every step.
---
# Quick-start

From nothing to a deployed site. Every output block below is real.

## 1 · Install the binary

```sh
curl -fsSL https://cherrybomb.dev/install.sh | sh
```

Windows:

```sh
irm https://cherrybomb.dev/install.ps1 | iex
```

The installer detects your platform, downloads the release binary, **verifies it against the release's `SHA256SUMS`**, installs it, and proves it works:

```sh
cherry version
```

```text
cherry 0.1.0-rc.3
```

> [!NOTE]
> Elixir developers can skip the binary entirely: add `{:cherry, "~> 0.1"}` to a mix project and every command below is `mix cherry.<verb>`. Same verbs, same flags, same output, by construction.

## 2 · Make a site

A Cherry site is a directory with a config file and content. That's the whole format:

```sh
mkdir mysite && cd mysite
```

Create `cherry.exs`:

```elixir
[
  title: "My Site",
  url: "https://example.com",
  description: "Notes from the orchard."
]
```

Create your home page at `content/pages/index.md`:

```markdown
---
title: Home
description: The front door.
---
# Hello

Welcome to my site.
```

> [!TIP]
> With Elixir installed you can scaffold all of this in one command: `mix archive.install hex cherry_new`, then `mix cherry.new mysite`. The scaffold includes a deploy workflow and an `AGENTS.md`, so the repo works out of the box whether a shell script or a coding agent is doing the publishing. The [Elixir guide](/guides/elixir/) covers that whole mode.

## 3 · Write a post

```sh
cherry gen.post "Growing season" --json
```

```json
{
  "ok": true,
  "command": "gen.post",
  "data": {
    "date": "2026-08-14",
    "path": "content/posts/2026-08-14-growing-season.md",
    "slug": "growing-season"
  }
}
```

Open `data.path` and write. The file starts as `draft: true`, so it shows up in the dev server but stays out of real builds until you publish it.

## 4 · See it

```sh
cherry serve
```

Live reload on every save, drafts included. Leave it running while you write.

## 5 · Verify and build

```sh
cherry check --strict
cherry build
```

```text
Built 12 page(s), 2 asset(s) → _site
```

`check` fails loudly on broken links, missing descriptions, images without alt text, and duplicate titles (see [the verifier](/guides/check/)). `_site/` is the whole deliverable: HTML, feeds, sitemap, `llms.txt`, and a markdown mirror of every page.

## 6 · Deploy

```sh
cherry gen.action --json
```

```json
{
  "ok": true,
  "command": "gen.action",
  "data": {
    "path": ".github/workflows/pages.yml",
    "cname": "example.com",
    "branch": "main"
  }
}
```

Commit, push, and flip one switch in your repo: **Settings → Pages → Source → GitHub Actions**. Every push to `main` now builds and deploys. The [deploy guide](/guides/deploy/) covers custom domains and project pages.
