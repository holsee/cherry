---
title: Using Cherry from Elixir
description: The hex package behind the binary. cherry_new scaffolding, mix task parity, and the library API for custom tooling.
---
# Using Cherry from Elixir

The `cherry` binary is a convenience wrapper. Underneath it is an ordinary hex package, and if you already live in Elixir you can skip the binary entirely: same verbs, same flags, same output, plus a library API the binary doesn't give you.

## Scaffold with cherry_new

[`cherry_new`](https://hex.pm/packages/cherry_new) is the project generator, a tiny separate package whose only job is to give you `mix cherry.new` before you have Cherry itself. It's the same pattern Phoenix uses with `phx_new`: install it once as a mix archive and the task is available globally, outside any project.

```sh
mix archive.install hex cherry_new
mix cherry.new mysite
```

The scaffold is a complete site: content directories, a `cherry.exs` config, a first post, a GitHub Pages deploy workflow, and an `AGENTS.md` describing the publish loop for any coding agent helping run the site. Its `mix.exs` depends on the cherry release that matches the installer:

```elixir
def deps do
  [
    {:cherry, "~> 0.4.0"}
  ]
end
```

`mix deps.get`, and everything below works.

## Every verb is a mix task

Flag for flag, `cherry <verb>` is `mix cherry.<verb>`, and each one takes `--json` for a structured envelope:

| task | what it does |
|---|---|
| `mix cherry.build` | build the site to `_site/`, plain files, deploy anywhere |
| `mix cherry.serve` | live-reloading dev server, drafts included |
| `mix cherry.check --strict` | build in memory and return structured diagnostics |
| `mix cherry.gen.post "Title"` | scaffold a dated draft post with valid frontmatter |
| `mix cherry.publish SLUG` | flip the draft flag, re-date, move the file (a path works too) |
| `mix cherry.schema COLLECTION` | print a collection's frontmatter schema |
| `mix cherry.gen.action` | generate the GitHub Pages deploy workflow |
| `mix cherry.gen.project` / `gen.talk` | portfolio scaffolds |
| `mix cherry.gen.theme NAME --from THEME` | scaffold a site-local theme from an official one |
| `mix cherry.theme.list` / `theme.which` | inspect available themes and the active one |
| `mix cherry.theme.eject TEMPLATE` | take ownership of one template, with provenance |
| `mix cherry.theme.diff --apply` | three-way drift status for every ejected overlay |
| `mix cherry.theme.tokens` | the theme's styling API: tokens, defaults, docs, overrides |
| `mix cherry.config KEY VALUE` | read and write cherry.exs surgically, tokens included |
| `mix cherry.version` | print the version |

> [!NOTE]
> `cherry upgrade` is the one binary-only verb: under mix the swap is refused, because your version is pinned by `mix.exs`. Upgrade the way you upgrade anything else: `mix deps.update cherry`. `mix cherry.upgrade --check` still works anywhere and tells you what's newer.

## The library API

The tasks are thin wrappers over public functions, so custom tooling composes without shelling out. `Cherry.build/1` returns the whole build as data:

```elixir
{:ok, build} = Cherry.build(source: ".", output: "_site")

length(build.pages)
#=> 16

Enum.map(build.assets, & &1.path)
#=> ["assets/site.css", "assets/theme-toggle.js", "assets/copy-code.js"]
```

`Cherry.check/1` builds in memory, writes nothing, and hands back diagnostics as structs:

```elixir
{:ok, _build, diagnostics} = Cherry.check(source: ".")

for d <- diagnostics do
  {d.severity, d.rule, d.file, d.message}
end
#=> [{:error, "broken-link", "content/pages/reading.md",
#=>   "links to /guides/pruning/, which this build does not emit"}]
```

Anything the [verifier](/guides/check/) reports on the command line is right there as `%Cherry.Check.Diagnostic{}` values. The full API is on [hexdocs.pm/cherry](https://hexdocs.pm/cherry), organised by area: core, content, themes, portfolio, pipeline.

## When to pick which mode

The binary and the hex package build byte-identical sites; the choice is only about your toolchain. No Elixir on the machine, or CI that should stay toolchain-free: use the [binary and the build action](/guides/deploy/). An Elixir project, custom pipeline stages, or your own tooling around builds: use the package. Moving between them is nothing: the site directory is the same either way.
