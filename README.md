<p align="center">
  <img src="assets/docs/cherrybomb_text_web.webp" alt="CherryBomb" width="520">
</p>

<p align="center">
  <strong>A static site generator for hackers.</strong><br>
  Fast static pages · a proper blog · your developer story — with first-class support
  for the agents that help you build it.
</p>

<p align="center">
  <a href="https://hex.pm/packages/cherry"><img src="https://img.shields.io/hexpm/v/cherry.svg" alt="Hex version"></a>
  <a href="https://hexdocs.pm/cherry"><img src="https://img.shields.io/badge/hex-docs-8e7ce6.svg" alt="Hex docs"></a>
  <a href="https://github.com/holsee/cherry/actions/workflows/ci.yml"><img src="https://github.com/holsee/cherry/actions/workflows/ci.yml/badge.svg?branch=develop" alt="CI status"></a>
  <a href="https://hex.pm/packages/cherry"><img src="https://img.shields.io/hexpm/l/cherry.svg" alt="License"></a>
</p>

<p align="center">
  <a href="https://cherrybomb.dev">cherrybomb.dev</a> ·
  <a href="https://cherrybomb.dev/guides/">Guides</a> ·
  <a href="https://github.com/holsee/cherry/blob/develop/DESIGN.md">Design</a> ·
  <a href="https://github.com/holsee/cherry/tree/develop/docs/adr">ADRs</a> ·
  <a href="CHANGELOG.md">Changelog</a>
</p>

---

CherryBomb is a modern take on [Octopress](http://octopress.org): your site is a repo,
publishing is a task/push, everything is hackable — without the part where upgrading the
framework ruins your week. The engine is Elixir, the CLI is `cherry`, and the output
is **plain HTML** you can host anywhere.

## Install

One line, no toolchain:

```sh
curl -fsSL https://cherrybomb.dev/install.sh | sh   # macOS / Linux
irm https://cherrybomb.dev/install.ps1 | iex        # Windows
```

Upgrading is `cherry upgrade` — checksum-verified against the release, rustup-style.

## Use from Elixir

Cherry is an ordinary hex package; the binary is just a convenience wrapper around it.

### Scaffolding: `cherry_new`

[`cherry_new`](https://hex.pm/packages/cherry_new) is the project generator — a tiny
separate package whose only job is to give you `mix cherry.new mysite` before you
have Cherry itself, the same pattern Phoenix uses with `phx_new`. Install it once as
a mix archive and the task is available globally, outside any project:

```sh
mix archive.install hex cherry_new
mix cherry.new mysite
```

The scaffold is a complete site: content directories, a `cherry.exs` config, a first
post, a GitHub Pages deploy workflow, an `AGENTS.md` describing the publish loop, and
a `mix.exs` that depends on the cherry release matching the installer — from there
the site's own `{:cherry, "~> 0.6.1"}` dependency pulls the real framework:

```elixir
def deps do
  [
    {:cherry, "~> 0.6.1"}
  ]
end
```

### The tasks

Every `cherry <verb>` is also `mix cherry.<verb>`, flag for flag, and every one of
them takes `--json` for a structured envelope:

| task | what it does |
|---|---|
| `mix cherry.build` | build the site → `_site/`, plain files, deploy anywhere |
| `mix cherry.serve` | live-reloading dev server, drafts included |
| `mix cherry.check [--strict]` | build in memory, return structured diagnostics — the verifier |
| `mix cherry.gen.post "Title"` | scaffold a dated draft post with valid frontmatter |
| `mix cherry.publish PATH` | flip the draft flag, re-date, move the file |
| `mix cherry.schema COLLECTION` | print a collection's frontmatter schema — never guess |
| `mix cherry.gen.action` | generate the GitHub Pages deploy workflow |
| `mix cherry.gen.project` / `gen.talk` | portfolio scaffolds (positions, talks) |
| `mix cherry.gen.theme NAME [--from THEME]` | scaffold a site-local theme from an official one |
| `mix cherry.theme.list` / `theme.which` | inspect available themes and the active one |
| `mix cherry.theme.eject TEMPLATE` | take ownership of one template, with provenance |
| `mix cherry.theme.diff [--apply]` | three-way drift status for every ejected overlay |
| `mix cherry.upgrade --check` | report newer releases (the self-swap itself is binary-only; under mix, upgrade with `mix deps.update cherry`) |
| `mix cherry.version` | print the version |

### As a library

`Cherry.build/1` and `Cherry.check/1` return structs (`Cherry.Build`,
`Cherry.Check.Diagnostic`), so custom tooling composes without shelling out — see
the [API docs](https://hexdocs.pm/cherry).

## Quickstart

```sh
cd mysite
cherry gen.post "Hello, world"
cherry serve                      # live-reloading dev server
cherry build                      # → _site/, plain files, deploy anywhere
cherry gen.action                 # GitHub Pages workflow, done
```

For the long version, [`demo/GUIDE.md`](https://github.com/holsee/cherry/blob/main/demo/GUIDE.md) builds a complete blog
and portfolio from nothing using only the CLI, with every command's real
output. The site it produces is [`demo/site`](https://github.com/holsee/cherry/tree/main/demo/site), and CI keeps the two
in agreement.

## What you get

**Fast static pages.** Prerendered HTML, zero JavaScript by default. Enhancements
(theme toggle, search) are tiny islands that fail soft.

**A blog that behaves.** Markdown + YAML frontmatter, validated against a schema at
build time — errors name the file and the field. Tags, drafts, future posts, Atom +
JSON feeds, sitemap, canonical URLs, OpenGraph and JSON-LD, all default-on.

**A developer story, not a résumé.** The portfolio is data: positions, projects,
talks, open source — rendered as a timeline, cross-linked with your blog through one
shared tag taxonomy. The "Elixir" page shows your jobs, projects, *and* every post
you've written about it.

**…and a CV when you need one.** The same data also renders at `/cv/` as a web page
that reads like a CV — link employers to it instead of attaching a file. Every skill
claim links to its evidence in your story, it prints pixel-perfect, exports as
JSON Resume at `/cv.json`, and has an unlisted mode for quiet job hunts.

**Themes you can actually swap.** Themes implement a versioned contract (templates +
design tokens), so switching is one config line. Customization is a ladder — config →
tokens → CSS → eject a template — and ejects record provenance, so theme upgrades
three-way-merge instead of silently stranding your copies.

**Light and dark, properly.** Token-driven, honors system preference, manual toggle
wins, no flash of the wrong theme — and code blocks follow along at zero JS cost.

**Agents are users too.** Every command takes `--json` and returns structured
results. `cherry check` verifies links, SEO, and schemas with machine-readable
diagnostics. `cherry schema posts --json` tells an agent exactly what valid
frontmatter is *before* it writes. New sites ship an `AGENTS.md`. Published sites
emit `llms.txt` and a markdown mirror of every page — readable without scraping.

**Host anywhere.** `_site/` is plain files. GitHub Pages and Cloudflare are
first-class: `cherry gen.action` writes the whole pipeline for either
(`--host cloudflare` emits a `wrangler.jsonc` plus deploy workflow for
Workers static assets) — Netlify, S3, or rsync work just as well.

## Hack it

A Cherry site is a thin Elixir project depending on the `cherry` package — so a
"plugin" is just a module in your repo hooking a pipeline stage, and a framework
upgrade is a version bump. Binary-mode sites (no `mix.exs`) extend via `extensions/*.exs`
scripts and can graduate to a full mix project by adding one file.

Builds are deterministic by contract: same input, byte-identical output.

## Status

**v0.4.0 is out**: first-class Cloudflare deploys (`cherry gen.action
--host cloudflare` writes the `wrangler.jsonc` and workflow for Workers
static assets), and the dev server now honours `base_path`, serving
subpath sites exactly as production will — on top of 0.3.0's named
dev-server URLs via [cherrypicker](https://github.com/holsee/cherrypicker)
(`cherry serve --name mysite`), `PORT` env support, and 0.2.0's `cherry new` scaffolding, HEEx templates, content components,
`light-dark()` theme tokens with the customization ladder, pure-Elixir
search, and the dual-stack dev server. The CLI is complete
enough to run a site end to end without an editor —
[demo/GUIDE.md](https://github.com/holsee/cherry/blob/main/demo/GUIDE.md) proves it,
command by command. [cherrybomb.dev](https://cherrybomb.dev) is Cherry's own dogfood,
built from [`example/`](https://github.com/holsee/cherry/tree/develop/example) on
every push. Cherry is built in the open, README-first:
[DESIGN.md](https://github.com/holsee/cherry/blob/develop/DESIGN.md) is the
constitution and [docs/adr/](https://github.com/holsee/cherry/tree/develop/docs/adr)
records the decisions.

## License

Dual-licensed under [MIT](https://github.com/holsee/cherry/blob/develop/LICENSE-MIT)
or [Apache 2.0](https://github.com/holsee/cherry/blob/develop/LICENSE-APACHE) — your
choice. Contributions are accepted under the same dual license.

The CherryBomb brand assets (logo, mascot, wordmark, and their derivatives such
as the favicon and og-card) are **not** covered by either license — they may not
be reused as your own branding. See
[assets/LICENSE](https://github.com/holsee/cherry/blob/develop/assets/LICENSE).
