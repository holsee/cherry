# Cherry, end to end, from the command line

This guide builds [`demo/site`](site) — a working blog and portfolio — from
nothing, using only the `cherry` CLI. Every command below was run; every output
block is real, copied from the run that produced the site next to this file.

Read it start to finish the first time. After that, each section stands alone.

**Conventions.** Long absolute paths in output blocks are shortened for
readability; nothing else is edited. Commands are written for the standalone
binary (`cherry build`).
If you installed Cherry as an Elixir dependency instead, every verb is a mix
task with the same name and flags: `mix cherry.build`. Inside this repository,
add `--source demo/site` to point at the demo rather than the current directory.

**Contents**

1. [Install, and prove it](#1-install-and-prove-it)
2. [Plant a site](#2-plant-a-site)
3. [Configure it without an editor](#3-configure-it-without-an-editor)
4. [Ask what a valid file looks like](#4-ask-what-a-valid-file-looks-like)
5. [Write, verify, publish](#5-write-verify-publish)
6. [Read the verifier properly](#6-read-the-verifier-properly)
7. [Build and preview](#7-build-and-preview)
8. [The portfolio and the CV](#8-the-portfolio-and-the-cv)
9. [Search without Node](#9-search-without-node)
10. [Themes, by provenance](#10-themes-by-provenance)
11. [Icons and static files](#11-icons-and-static-files)
12. [Deploy to GitHub Pages](#12-deploy-to-github-pages)
13. [Stay current](#13-stay-current)
14. [The machine surface](#14-the-machine-surface)
15. [Every verb](#15-every-verb)

---

## 1. Install, and prove it

Cherry ships as a single self-contained binary. Install it with one of:

```bash
curl -fsSL https://cherrybomb.dev/install.sh | sh     # macOS, Linux
irm https://cherrybomb.dev/install.ps1 | iex          # Windows PowerShell
```

If you already have an Elixir toolchain you can use Cherry as a dependency
instead — `{:cherry, "~> 0.1.0"}` in a site's `mix.exs` — and every verb
below becomes `mix cherry.<verb>`. You need nothing else: no Node, no bundler,
no runtime.

Then confirm what you are actually running:

```console
$ cherry version
cherry 0.1.0 (4dae966)
```

The parenthesised value is the git commit the binary was compiled from. It
matters when you are between releases: two builds can both call themselves
`0.1.0` and differ. A build compiled from a hex package has no revision
and prints just the version.

Everything is scriptable from here on. Add `--json` to any verb for a machine
envelope, and rely on the exit codes: **0** success, **1** the command ran and
failed, **2** you used it wrong.

## 2. Plant a site

There are two starting points, and which one you get depends on how you
installed Cherry.

### With the Elixir toolchain

`cherry_new` is a separate archive whose only job is to scaffold, the way
`phx_new` does for Phoenix:

```console
$ mix archive.install hex cherry_new
$ mix cherry.new junovale
* creating README.md
* creating AGENTS.md
* creating .claude/skills/publish/SKILL.md
* creating content/pages/index.md
* creating content/pages/about.md
* creating content/posts/2026-08-16-hello-cherry.md
* creating static/images/.gitkeep

Your orchard is planted at /tmp/junovale. Next:

    cd /tmp/junovale
    mix deps.get
    mix cherry.serve          # live-reloading dev server
    mix cherry.check          # the verifier agents build against
    mix cherry.gen.action     # GitHub Pages deploy workflow

AGENTS.md documents the whole workflow — point your agent at it.
```

You get a site, not a framework: markdown under `content/`, files to copy under
`static/`, one `cherry.exs`, and an `AGENTS.md` describing the loop for whatever
coding agent you point at it.

### With the standalone binary only

There is no `cherry new` — scaffolding lives in the mix archive above, so a
binary-only install has nothing to run it. The gap is one file wide, and worth
knowing exactly how wide:

```bash
mkdir -p junovale/content/posts junovale/content/pages
cd junovale
cat > cherry.exs <<'EOF'
[
  title: "Juno Vale",
  url: "https://junovale.example"
]
EOF
```

That is the whole bootstrap. `cherry.exs` has to exist before any verb works —
including `cherry config`, which reads a site before it writes one — but from
here everything is commands:

```console
$ cherry config
author         Juno Vale
base_path      /
description    (unset)
nav            0 entries

$ cherry gen.post "First" --json
{"command":"gen.post","data":{"date":"2026-08-16","path":"content/posts/2026-08-16-first.md","slug":"first"},"ok":true}
```

Run `cherry check` at this point and it will tell you what a site still needs:

```console
$ cherry check
error: Checked 8 page(s): 3 error(s), 0 warning(s).
  [error] :not_found: broken-link — links to /, which this build does not emit
  [error] :post_list: broken-link — links to /, which this build does not emit
```

Those are the theme's own links to a home page you have not written yet. Add
`content/pages/index.md` with a `title:` and they go away — which is a fair
introduction to how the verifier behaves generally: it tells you what is
missing, in terms of the file that would fix it.

> **What `demo/site` omits.** The scaffold also writes `mix.exs` and
> `config/config.exs` so the site can carry its own Cherry dependency. The demo
> is built by the Cherry checkout it lives inside, so those two are redundant
> and were deleted. Nothing else about it differs from a fresh scaffold.

## 3. Configure it without an editor

`cherry.exs` is the whole of a site's configuration, and `cherry config` reads
and writes it. This is what the demo's settings came from:

```console
$ cherry config title "Juno Vale"
title: Junovale → Juno Vale (written to cherry.exs)

$ cherry config url "https://junovale.example"
url: https://example.com → https://junovale.example (written to cherry.exs)

$ cherry config search cherry
search: (unset) → cherry (written to cherry.exs)
```

Three properties worth knowing, because they are what make this safe to
automate:

**Only the value changes.** The scaffold's comments are still there afterwards:

```elixir
# Site configuration — every key is documented in Cherry's Site schema.
[
  title: "Juno Vale",
  # Set this to the site's real URL before deploying: canonical links,
  # feeds, and sitemap all derive from it.
  url: "https://junovale.example",
  description: "Notes on the BEAM, backpressure, and the long tail of distributed systems.",
  author: "Juno Vale",
  search: "cherry"
]
```

**A bad value is refused, not written.** Every write reloads the site to prove
the result is valid, and restores the file if it is not:

```console
$ cherry config search algolia
error: cherry.exs: invalid value for :search option: expected one of ["cherry", "pagefind"], got: "algolia" — cherry.exs left unchanged
$ echo $?
2
```

**Reading tells you the resolved value.** With no arguments it prints
everything; with a key, one value:

```console
$ cherry config
author         Juno Vale
base_path      /
description    Notes on the BEAM, backpressure, and the long tail of distributed systems.
nav            0 entries
search         cherry
social_image   (unset)
theme          default
title          Juno Vale
url            https://junovale.example
```

Note `author`: it was never set explicitly, and it resolves to the site title,
because that is the schema's default. `config` shows you what the site *is*,
not what the file says.

Structured settings — `nav:` and anything else that is a list — are refused
rather than rewritten, so the CLI can never mangle their formatting. Edit those
in the file.

## 4. Ask what a valid file looks like

Never guess frontmatter. Every collection can describe itself:

```console
$ cherry schema posts
posts frontmatter:
  title: string (required) — Post title.
  date: date — ISO 8601 date; defaults to the date in the filename.
  slug: string — URL slug; defaults to the filename after the date.
  tags: list of string [default: []] — Tags from the shared site taxonomy (also used by the portfolio).
  draft: boolean [default: false] — Drafts are skipped unless `--drafts`.
  description: string — Meta description for SEO and feeds.
```

Run it bare to see what exists:

```console
$ cherry schema
error: usage: cherry schema COLLECTION — available: pages, portfolio/education, portfolio/oss, portfolio/positions, portfolio/projects, portfolio/talks, posts
```

`--json` gives the same information as data, which is the form to use when
something else is generating the file.

## 5. Write, verify, publish

Three commands and one act of writing. The generator gives you a valid file;
you supply the prose; the verifier and `publish` do the rest.

```console
$ cherry gen.post "Backpressure Is a Product Decision" --today 2025-02-11 --json
{"command":"gen.post","data":{"date":"2025-02-11","path":"content/posts/2025-02-11-backpressure-is-a-product-decision.md","slug":"backpressure-is-a-product-decision"},"ok":true}
```

The envelope hands you both things you need next: `path` to write to, `slug` to
publish by. What lands on disk is a draft:

```markdown
---
title: "Backpressure Is a Product Decision"
draft: true
tags: []
---
```

Write the body and fill in `description:` and `tags:`. Drafts are invisible to
`build` and to feeds, but `serve` shows them, so you can read your own draft in
place.

Then publish:

```console
$ cherry publish backpressure-is-a-product-decision --today 2025-02-11 --json
{"command":"publish","data":{"date":"2025-02-11","to":"content/posts/2025-02-11-backpressure-is-a-product-decision.md","from":"content/posts/2025-02-11-backpressure-is-a-product-decision.md"},"ok":true}
```

> **`publish` re-dates the post to today unless you say otherwise.** That is
> usually what you want — a draft becomes a post on the day it goes out — but it
> means a draft written weeks ago gets today's filename and today's position in
> the feed. Pass `--today YYYY-MM-DD` when the date is part of the content. The
> six posts in this demo are dated across 2025 and 2026 for exactly that reason.

Capture `from` and `to`. Here they match, because `--today` gave the post the
date its filename already had. Publish without it and they differ — the file is
renamed to today — and anything linking to the old path needs updating.

## 6. Read the verifier properly

`cherry check` builds the whole site in memory and writes nothing. It is the
fastest way to find out whether the tree is publishable.

```console
$ cherry check --strict
Checked 74 page(s): all clear.
```

When it is not clear, it says exactly where and why:

```console
$ cherry check --strict
error: Checked 76 page(s): 2 error(s), 0 warning(s).
  [error] content/posts/2026-06-01-draft-note.md: empty-body — no body — the page renders as a heading over nothing
  [error] content/posts/2026-06-01-draft-note.md: missing-description — no description: — search snippets and social cards fall back to nothing
```

Branch on the **rule**, never on the message text:

| rule | meaning |
|---|---|
| `broken-link` | an internal href resolves to nothing this build emits |
| `missing-description` | no `description:` — search snippets and social cards have nothing to use |
| `missing-alt` | an `<img>` with no alt text |
| `duplicate-title` | two documents share a title |
| `empty-body` | a post or page with no prose: a heading over nothing |
| `unfilled-field` | frontmatter still holding the empty string a generator wrote |
| `feed-missing` / `feed-invalid` | Atom or JSON Feed sanity |
| `stale-overlay` / `untracked-overlay` | theme drift — see [§10](#10-themes-by-provenance) |

`--strict` promotes warnings to errors, which is what you want in CI. Without
it, warnings are reported and only errors fail the run.

For automation, take the structured form:

```console
$ cherry check --json
{"command":"check","data":{"errors":0,"warnings":0,"diagnostics":[],"pages":74},"ok":true}
```

A failing check exits 1 with `error.code == "check_failed"` and the full
diagnostic list under `error.details.diagnostics`, each entry carrying `file`,
`rule`, `message`, and `severity`.

## 7. Build and preview

```console
$ cherry build
Built 74 page(s), 4 asset(s) → demo/site/_site
```

The build is deterministic: same inputs, same bytes. That is a property you can
test in CI, and it is why the search index is generated in-process rather than
by an external tool.

For writing, use the server:

```console
$ cherry serve --port 0
Serving with live reload at http://localhost:41657 — Ctrl-C to stop.
```

`--port 0` binds a free ephemeral port and reports it, so a busy port 4000
cannot fail a scripted run. Drafts are included. Editing content rebuilds and
reloads the browser; a broken edit keeps the last good output on screen and
prints the diagnostics.

> **Check the banner, not your assumptions.** If it says *"Serving at … (live
> reload unavailable)"*, the filesystem is not delivering change events — the
> usual cause is a Docker bind mount or a network share. Cherry proves the
> watcher works before claiming it, so this is a real answer rather than a
> silence. Rebuild explicitly when you see it. The `--json` envelope carries the
> same fact as `live_reload`.

## 8. The portfolio and the CV

The portfolio is five collections — projects, talks, positions, education, oss —
that share the site's tag taxonomy with the blog. Two of them have generators:

```console
$ cherry gen.project "Ledgerbeam" --json
{"command":"gen.project","data":{"path":"content/portfolio/projects/ledgerbeam.md","slug":"ledgerbeam"},"ok":true}

$ cherry gen.talk "Backpressure in Practice" --json
{"command":"gen.talk","data":{"path":"content/portfolio/talks/backpressure-in-practice.md","slug":"backpressure-in-practice"},"ok":true}
```

Positions, education and oss entries have no generator yet — write the file and
let `cherry schema portfolio/positions` tell you the fields. A position looks
like this:

```yaml
---
title: "Staff Engineer"
org: "Ledgerbeam"
start: 2023-03-06
location: "Porto (remote)"
tags: [elixir, distributed-systems, event-sourcing]
highlights:
  - "Led the move from mutable stock levels to an event-sourced movement stream"
cv:
  include: true
  weight: 10
---
```

Two fields do the interesting work:

**`tags:`** are shared with posts. Any tag used by both a portfolio entry and a
blog post gets a **story page** at `/story/TAG/`, which threads the writing and
the work together. The demo has eleven of them; `/story/event-sourcing/` is the
one the home page links to.

**`cv:`** curates. An entry with `cv: {include: true, weight: N}` appears in the
CV view, ordered by weight; an entry without one stays on the timeline only.
That is how a portfolio of everything produces a CV of the relevant parts,
without a second copy of the truth.

Everything lands at `/portfolio/` as a reverse-chronological timeline.

## 9. Search without Node

```console
$ cherry config search cherry
search: (unset) → cherry (written to cherry.exs)
```

That is the whole setup. The next build emits an inverted index and a small
browser island:

```
_site/search/index.json    16175 bytes   (4942 gzipped)
_site/search/search.js     2351 bytes
```

The index is built in-process from your parsed content: no Node, no npm, no
network, nothing to install on the machine that builds the site. Because it is
a pure function of the content, it lands inside the deterministic build like
any other page. Ranking is tf-idf, weighted so a word in a title outranks the
same word in a paragraph, with plural folding standing in for a stemmer.

Any theme gets a working search box by rendering the markup and pointing at the
two paths — the island ships from Cherry itself rather than from each theme.

The alternative is `search: "pagefind"`, which is a better engine — it indexes
rendered HTML, handles many languages, and has a richer UI — at the price of
Node and npm registry access on whatever machine builds the site. Choose
deliberately; the demo uses the built-in one to keep the toolchain at one tool.

## 10. Themes, by provenance

Most restyles never need a template. Climb this ladder and stop at the first
rung that does the job:

1. **Pick a theme** — `theme: "cherrybomb"` in `cherry.exs`.
2. **Override tokens** — the theme's public styling API.
3. **Append CSS** — `assets/custom.css`, loaded last, always.
4. **Eject a template** — with provenance, shown below.
5. **Own the theme** — `cherry gen.theme`.

Rung 2 starts with looking. Every token the theme declares, with its default,
what it does, and any override you have in place:

```console
$ cherry theme.tokens
tokens of theme default:
  --color-bg             light-dark(#ffffff, #15171b)
                         Page background.
  --color-accent         light-dark(#b3173e, #f4718c)
                         Links and interactive accents.
  --measure              42rem
                         Reading column width (~66ch).
  …
```

Every color is one `light-dark(light, dark)` pair — both renditions in a
single value. Overriding one is a config write, not a CSS file, and the demo
site runs with its accent moved to violet exactly this way:

```console
$ cherry config tokens.--color-accent "light-dark(#7c3aed, #a78bfa)" --json
{"command":"config","data":{"key":"tokens.--color-accent","path":"cherry.exs","previous":null,"value":"light-dark(#7c3aed, #a78bfa)"},"ok":true}
```

The name must exist in `theme.tokens` — a typo is refused here, with the
nearest real token named, instead of becoming a dead line in `cherry.exs`.
A plain value (`"#7c3aed"`) works too and applies to both renditions.

Rung 3 is a file: anything in `assets/custom.css` ships as
`/assets/custom.css` and loads after everything else. Theme CSS lives inside
`@layer theme`, and your overrides — tokens and custom.css both — are
unlayered, so yours win by declaration, never by specificity fights.

When a restyle really is structural, continue to rung 4. Start by looking:

```console
$ cherry theme.list
default 0.1.0 (contract 1.0)
  /path/to/cherry/priv/themes/default
templates:
  layout     theme
    assigns: site, inner, page_title, head_extra, nav, search, page_class
  page       theme
```

Templates resolve through three levels, and `theme.which` shows the chain and
the winner:

```console
$ cherry theme.which post
post:
  site_overlay  demo/site/themes/default/templates/post.html.eex (missing)
  theme         .../priv/themes/default/templates/post.html.eex ← renders
  framework     .../priv/themes/default/templates/post.html.eex
```

To change one template, take ownership of it — never copy it by hand:

```console
$ cherry theme.eject post_list --json
{"command":"theme.eject","data":{"ejected":[{"path":"demo/site/themes/default/templates/post_list.html.eex","template":"post_list"}]},"ok":true}
```

The ejected file gets a provenance header recording the theme, version, and
hash it came from:

```eex
<%!-- cherry:eject theme=default version=0.1.0 sha256=8abba9f1… --%>
```

That header is what makes upgrades survivable. The demo's copy now groups posts
by year and shows each description — edit yours freely, then ask what state it
is in:

```console
$ cherry theme.diff
default 0.1.0 overlays:
  post_list            current
```

After a Cherry upgrade, that column is the whole story: `current` needs nothing,
`auto_updatable` re-ejects cleanly with `--apply`, `conflict` means both you and
upstream changed it and you must merge, and `untracked` means a file with no
provenance — re-eject to adopt it.

For a whole theme of your own, `cherry gen.theme NAME` forks one, and two
commands make it live:

```bash
cherry gen.theme orchard
cherry config theme themes/orchard
```

A theme that lives inside your site is yours outright: it has no overlay level,
so `theme.diff` reports nothing to drift and `theme.eject` refuses, pointing you
at the file to edit directly.

## 11. Icons and static files

Everything in `static/` is copied to the site root. Three names are special —
`favicon.ico`, `favicon.svg`, and `apple-touch-icon.png` — and are linked from
every page automatically when present. The demo ships one:

```console
$ grep -o 'rel="icon"[^>]*' _site/index.html
rel="icon" type="image/svg+xml" href="/favicon.svg"
```

No configuration; put the file there and it is wired up.

## 12. Deploy to GitHub Pages

```console
$ cherry gen.action --branch main
Wrote .github/workflows/pages.yml (CNAME: junovale.example) — enable it once under Settings → Pages → Source → GitHub Actions.
```

The workflow builds on every push to the named branch, runs `check --strict`
before publishing anything, and deploys. Note that it derived a `CNAME` step
from the site's `url:` — that happens for a custom domain and is skipped for
`*.github.io` and project-pages sites, so set `url` correctly *before*
generating.

Then, once per repository, switch the publishing source to GitHub Actions. In
the settings UI, or from the CLI:

```bash
gh api -X PUT repos/OWNER/REPO/pages -f build_type=workflow
```

Order matters: `actions/deploy-pages` refuses to deploy unless the source is
already GitHub Actions, so flip it before the first deploying run, not after.

## 13. Stay current

```console
$ cherry upgrade --check --json
{"command":"upgrade","data":{"status":"up_to_date","target":"v0.1.0","asset":"cherry-linux-x86_64","current":"0.1.0"},"ok":true}
```

`--check` reports and touches nothing. Statuses are `up_to_date`, `outdated`,
and `no_stable_release` — the last one succeeds too, because "there is nothing
stable yet" is an answer, not a failure.

`cherry upgrade` downloads this platform's asset, verifies it against the
release's `SHA256SUMS`, and swaps the running executable in place. Any checksum
problem aborts and leaves the current binary untouched. Prereleases never
arrive uninvited; target one explicitly with `--version v0.2.0-rc.1`.

Under mix, upgrade the dependency instead — `mix deps.update cherry` — which
`cherry upgrade` will tell you.

## 14. The machine surface

Cherry is built to be driven by something other than a human, and the demo site
carries the whole surface.

**Every verb speaks JSON.** `--json` produces one envelope on stdout:

```json
{"ok":true,"command":"check","data":{"errors":0,"warnings":0,"diagnostics":[],"pages":74}}
```

Failures use the same shape with `"ok":false` and an `error` object carrying
`code`, `message`, and `details`. Branch on `code`, which is stable, rather than
on prose, which is not.

**Exit codes mean something.** 0 succeeded, 1 ran and failed (a check with
errors, a download that would not verify), 2 you used it wrong (unknown flag,
missing argument, invalid value).

**The published site is readable by machines.** Beside every page there is an
`index.md` mirror of its markdown; `/llms.txt` indexes the site for language
models; `/feed.xml` and `/feed.json` carry the posts. Read those instead of
scraping HTML.

**There is a skill for coding agents.** Cherry ships one at
`skills/cherry/SKILL.md`, and `mix cherry.new` drops an `AGENTS.md` into the site.
Point your agent at either and it will follow this same loop.

## 15. Every verb

| verb | what it does |
|---|---|
| `cherry version` | version, and the commit it was built from |
| `cherry schema COLLECTION` | the frontmatter contract for a collection |
| `cherry config [KEY [VALUE]]` | read or write `cherry.exs` |
| `cherry gen.post TITLE` | new draft post |
| `cherry gen.project NAME` | new portfolio project |
| `cherry gen.talk TITLE` | new portfolio talk |
| `cherry gen.theme NAME` | fork a theme into the site |
| `cherry gen.action` | GitHub Pages deploy workflow |
| `cherry publish SLUG` | draft → published, dated |
| `cherry build` | build to `_site/` |
| `cherry check [--strict]` | verify without writing |
| `cherry serve [--port N]` | dev server with live reload |
| `cherry theme.list` | active theme, templates, tokens |
| `cherry theme.tokens` | the styling API: tokens, defaults, overrides |
| `cherry theme.which TEMPLATE` | resolution chain for one template |
| `cherry theme.eject TEMPLATE` | take ownership, with provenance |
| `cherry theme.diff` | drift status of every overlay |
| `cherry upgrade [--check]` | update the standalone binary |

Every one of them takes `--json`, and every one that reads a site takes
`--source DIR`.

---

## Where to go next

Read [`site/`](site) — it is the output of this guide, and small enough to read
in full. Then run the loop on your own content:

```bash
mix cherry.new mysite && cd mysite
cherry config url "https://example.com"
cherry gen.post "Hello"
cherry check --strict
cherry serve --port 0
```

If a command surprises you, that is a bug worth reporting: the CLI is meant to
be predictable enough to automate, and every verb here is covered by tests that
run on Linux, macOS, and Windows.
