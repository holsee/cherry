<p align="center">
  <img src="assets/docs/cherrybomb_text_web.webp" alt="CherryBomb" width="520">
</p>

<p align="center">
  <strong>A static site generator for hackers.</strong><br>
  Fast static pages · a proper blog · your developer story — with first-class support
  for the agents that help you build it.
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
publishing is a task, everything is hackable — without the part where upgrading the
framework ruins your week. The engine is Elixir, the CLI is `cherry`, and the output
is plain HTML you can host anywhere.

## Install

One line, no toolchain:

```sh
curl -fsSL https://cherrybomb.dev/install.sh | sh   # macOS / Linux
irm https://cherrybomb.dev/install.ps1 | iex        # Windows
```

Upgrading is `cherry upgrade` — checksum-verified against the release, rustup-style.

## Use from Elixir

Cherry is an ordinary hex package; the binary is just a convenience wrapper around it.
Every `cherry <verb>` is also `mix cherry.<verb>`, flag for flag:

```elixir
def deps do
  [
    {:cherry, "~> 0.1.0-rc.1"}
  ]
end
```

```sh
mix cherry.gen.post "Hello, world"
mix cherry.serve
mix cherry.build
mix cherry.check --strict
```

Or drive it as a library — `Cherry.build/1` and `Cherry.check/1` return structs
(`Cherry.Build`, `Cherry.Check.Diagnostic`), so custom tooling composes without
shelling out. Scaffolding a new site is one archive away:

```sh
mix archive.install hex cherry_new
mix cherry.new mysite
```

## Quickstart

```sh
cd mysite
cherry gen.post "Hello, world"
cherry serve                      # live-reloading dev server
cherry build                      # → _site/, plain files, deploy anywhere
cherry gen.action                 # GitHub Pages workflow, done
```

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

**Host anywhere.** `_site/` is plain files. GitHub Pages is first-class (generated
Actions workflow, correct base-path handling for project pages, CNAME, `.nojekyll`)
— Netlify, Cloudflare, S3, or rsync work just as well.

## Hack it

A Cherry site is a thin Elixir project depending on the `cherry` package — so a
"plugin" is just a module in your repo hooking a pipeline stage, and a framework
upgrade is a version bump. Binary-mode sites (no `mix.exs`) extend via `extensions/*.exs`
scripts and can graduate to a full mix project by adding one file.

Builds are deterministic by contract: same input, byte-identical output.

## Status

**v0.1.0-rc.1 is out**: five release binaries with provenance attestation, the full
authoring loop, the verifier, both themes, the portfolio/CV views, self-upgrade, and
the agent skill. [cherrybomb.dev](https://cherrybomb.dev) is Cherry's own dogfood,
built from [`example/`](https://github.com/holsee/cherry/tree/develop/example) on
every push. Cherry is built in the open, README-first:
[DESIGN.md](https://github.com/holsee/cherry/blob/develop/DESIGN.md) is the
constitution and [docs/adr/](https://github.com/holsee/cherry/tree/develop/docs/adr)
records the decisions. Next stop: stable 0.1.0.

## License

Dual-licensed under [MIT](https://github.com/holsee/cherry/blob/develop/LICENSE-MIT)
or [Apache 2.0](https://github.com/holsee/cherry/blob/develop/LICENSE-APACHE) — your
choice. Contributions are accepted under the same dual license.

The CherryBomb brand assets (logo, mascot, wordmark, and their derivatives such
as the favicon and og-card) are **not** covered by either license — they may not
be reused as your own branding. See
[assets/LICENSE](https://github.com/holsee/cherry/blob/develop/assets/LICENSE).
