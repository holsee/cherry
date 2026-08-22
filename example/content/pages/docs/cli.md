---
title: The CLI
description: Every Cherry verb, its flags, its JSON envelope, and its exit code, in one page.
---
## The CLI

Nineteen verbs, one contract. Every command accepts `--json` for a machine-readable envelope and `--verbose` for more detail, and every command means its exit code:

| code | meaning |
|---|---|
| `0` | success; a `--json` envelope has `"ok": true` |
| `1` | the command ran and failed: a build error, a failed check |
| `2` | usage error: unknown flag, bad value, missing argument |

Verbs are identical under the standalone binary (`cherry build`) and the Elixir dependency (`mix cherry.build`), with one exception noted under [`new`](#cherry-new). Envelopes always have the same shape:

```json
{
  "ok": true,
  "command": "build",
  "data": {
    "output": "_site",
    "pages": 12,
    "assets": 4
  }
}
```

```json
{
  "ok": false,
  "command": "config",
  "error": {
    "code": "usage",
    "message": "...",
    "details": {}
  }
}
```

### Everyday

#### cherry new

```sh
cherry new PATH [--json]
```

Scaffolds a complete site: `cherry.exs`, a first post, index and about pages, `AGENTS.md`, and a `.claude` publish skill. Refuses a directory that already has anything in it, and the title humanises from the directory name (`juno-vale` becomes `Juno Vale`). A fresh scaffold builds and checks clean.

This is the one verb without a `mix cherry.new` twin in core: the mix lane scaffolds with the `cherry_new` archive (`mix archive.install hex cherry_new`), which writes the same site plus the mix project files, and owns that task name.

#### cherry serve

```sh
cherry serve [--source DIR] [--out DIR] [--port N] [--name NAME] [--json]
```

Builds once, then serves with live reload. Drafts are included, because this is your writing loop. Edits to content, static files, themes, or `cherry.exs` rebuild automatically and reload connected browsers; a broken edit keeps the last good output serving and prints its diagnostics instead of dying:

```text
rebuilt — reloading browsers
build failed (still serving the last good output):
validate: content/pages/about.md: required :title option not found
```

`--port 0` binds a free ephemeral port and reports it in the banner and envelope, which is exactly what you want in scripts and CI where port 4000 may be taken (`PORT` in the environment is honoured when `--port` is absent). `--name mysite` registers the bound port with a running [cherrypicker](https://github.com/holsee/cherrypicker) daemon so the site also answers at `http://mysite.localhost`; no daemon just means the port URL. A site with a `base_path` serves under that prefix, exactly as production will: the bare root redirects to it, and an unprefixed path that would 404 on the real host 404s in dev too. The server listens on both IPv4 and IPv6 (IPv4-only where the host has no IPv6), so `localhost` answers instantly even on systems that resolve it to `::1` first. Add `--verbose` for a request log: method, path, status, and response time per line. [How the server works inside](/the-embedded-server/) is a story of its own.

#### cherry build

```sh
cherry build [--source DIR] [--out DIR] [--drafts] [--future] [--json]
```

The production build, into `_site/` by default. `--drafts` includes posts marked `draft: true`; `--future` includes posts dated after today. Builds are byte-deterministic: the same tree in produces the same bytes out, which is gated in Cherry's own CI on every commit. See [the pipeline](/docs/pipeline/) for what happens between your markdown and the output tree.

#### cherry check

```sh
cherry check [--source DIR] [--strict] [--drafts] [--future] [--json]
```

The verifier. Builds the whole site in memory, writes nothing, and runs every rule: broken internal links, missing descriptions, images without alt text, duplicate titles, unfilled scaffolds, misused [content components](/docs/components/), feed sanity, and theme overlay drift. Diagnostics are structured, and each one names the file that would fix it:

```text
Checked 34 page(s): all clear.
```

`--strict` promotes warnings to errors, which is what the generated deploy workflow runs: a warning you have decided to tolerate is fine locally, but a broken link cannot reach production.

### Writing

#### cherry gen.post

```sh
cherry gen.post "Post title" [--source DIR] [--json]
```

One file in `content/posts/` named `YYYY-MM-DD-slug.md`, valid frontmatter, `draft: true`. The envelope carries the path and the slug:

```json
{
  "ok": true,
  "command": "gen.post",
  "data": {
    "date": "2026-08-19",
    "path": "content/posts/2026-08-19-sweep-post.md",
    "slug": "sweep-post"
  }
}
```

#### cherry publish

```sh
cherry publish SLUG [--source DIR] [--json]
cherry publish content/posts/2026-08-14-my-draft.md [--source DIR] [--json]
```

Turns a draft into a published post: removes the `draft:` line and renames the file to today's date, because the filename is the source of truth for a post's date. Name the draft by path or by the slug `gen.post` returned:

```json
{
  "ok": true,
  "command": "publish",
  "data": {
    "date": "2026-08-19",
    "from": "content/posts/2026-01-01-drafty.md",
    "to": "content/posts/2026-08-19-drafty.md"
  }
}
```

#### cherry gen.project and cherry gen.talk

```sh
cherry gen.project "Project name" [--source DIR] [--json]
cherry gen.talk "Talk title" [--source DIR] [--today DATE] [--json]
```

Scaffold [portfolio](/guides/portfolio-and-cv/) entries with valid frontmatter: projects land in `content/portfolio/projects/` with a `cv:` curation block ready to edit, talks in `content/portfolio/talks/` (add a `cv:` block yourself to put a talk on the CV).

#### cherry schema

```sh
cherry schema COLLECTION [--json]
```

Prints a collection's frontmatter contract: every field, its type, whether it is required, its default, and its doc. The collections are `pages`, `posts`, and the five portfolio collections (`portfolio/positions`, `portfolio/projects`, `portfolio/talks`, `portfolio/oss`, `portfolio/education`):

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

### Configuring

#### cherry config

```sh
cherry config [KEY [VALUE]] [--source DIR] [--json]
```

Reads and writes `cherry.exs` without an editor. No arguments prints the resolved configuration; a key prints one value; a key and a value writes. Three properties make it safe to automate:

- **Only the value changes.** Comments and layout in `cherry.exs` survive byte-for-byte.
- **A bad value is refused, not written.** Every write reloads the site to prove the result is valid, and restores the file if it is not.
- **Structured keys are protected.** Scalar keys (`title`, `url`, `description`, `author`, `theme`, `search`, `base_path`, `social_image`) are writable; `nav:` is refused rather than reformatted.

The exception is theme tokens, addressed with a dotted key and validated against the theme's manifest before the file is touched:

```text
$ cherry config tokens.--color-accent "#7c3aed"
tokens.--color-accent: light-dark(#b3173e, #f4718c) → #7c3aed (written to cherry.exs)

$ cherry config tokens.--color-acent "#111111"
error: tokens: --color-acent is not a token of theme default (did you mean --color-accent?) — `cherry theme.tokens` lists them
```

The full key reference lives in [Configuration](/docs/configuration/).

### Theming

The five `theme.*` verbs and `gen.theme` are covered in depth in [Theming](/docs/theming/); the short version:

| verb | does |
|---|---|
| `theme.list` | the active theme: contract, templates, tokens, overlay states |
| `theme.tokens` | the styling API: every token, default, doc, and site override |
| `theme.which TEMPLATE` | the resolution chain; the arrow marks the file that renders |
| `theme.eject TEMPLATE` | take ownership of one template, provenance recorded |
| `theme.diff [--apply]` | drift report for everything you own; `--apply` re-ejects safe updates |
| `gen.theme NAME --from THEME` | scaffold a complete editable theme from an official one |

### Shipping

#### cherry gen.action

```sh
cherry gen.action [--host github|cloudflare] [--source DIR] [--branch NAME] [--name NAME] [--force] [--json]
```

Writes your deploy pipeline. The default host, `github`, writes `.github/workflows/pages.yml`: on push to `--branch` (default `main`), install Cherry, run `cherry check --strict`, build, deploy to GitHub Pages. Adds `.nojekyll`, and a `CNAME` when your `url` is a custom domain. One-time repo setup: Settings, then Pages, then Source: GitHub Actions. `--host cloudflare` targets Cloudflare Workers static assets instead: writes `wrangler.jsonc` (Worker named by `--name`, default a slug of the site title) plus `.github/workflows/cloudflare.yml`, deploying with `wrangler deploy`; one-time setup is two repository secrets. Details in [Deploying](/docs/deploy/), [GitHub Pages guide](/guides/deploy/), and [Cloudflare guide](/guides/deploy-cloudflare/).

#### cherry upgrade

```sh
cherry upgrade [--check] [--version vX.Y.Z] [--json]
```

Upgrades the binary in place, rustup style: resolves the latest stable GitHub release, downloads this platform's binary, verifies it against the release's `SHA256SUMS`, and swaps the running executable. `--check` only reports:

```json
{
  "ok": true,
  "command": "upgrade",
  "data": {
    "status": "up_to_date",
    "current": "0.4.0",
    "target": "v0.4.0",
    "asset": "cherry-linux-x86_64"
  }
}
```

Mix users upgrade with `mix deps.update cherry` as ever.

#### cherry version

```sh
cherry version [--json]
```

```text
cherry 0.4.1 (d696feb)
```

The parenthesised value is the git commit the binary was compiled from, so a build from a branch is distinguishable from the release it was branched from. It is absent when Cherry was compiled from a hex package.
