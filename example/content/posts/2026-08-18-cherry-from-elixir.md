---
title: Cherry from Elixir
description: The hex package behind the binary, the library API, and the places where driving builds from code beats shelling out.
tags:
  - elixir
---
The `cherry` binary gets the headlines, but underneath it is an ordinary hex package, and if you already live in Elixir the library lane is quietly the more interesting one. This post is about when and why you would take it.

## The two lanes are the same code

There is no "embedded mode" with asterisks. The binary and the mix tasks are two thin front doors over one seam (a CLI registry mapping verbs to command modules), and both lanes build byte-identical sites. That is not marketing; it is a test in our suite. `mix cherry.build` is:

```elixir
def run(argv) do
  case Cherry.CLI.run(["build" | argv]) do
    0 -> :ok
    code -> exit({:shutdown, code})
  end
end
```

That is the whole task. Everything real lives one layer down, in public functions you can call yourself.

## The library API

`Cherry.build/1` returns the entire build as data:

```elixir
{:ok, build} = Cherry.build(source: "site", output: "_site")

length(build.pages)
#=> 16

Enum.map(build.assets, & &1.path)
#=> ["assets/site.css", "assets/theme-toggle.js", "assets/copy-code.js"]
```

`Cherry.check/1` is the verifier as a function: builds in memory, writes nothing, returns diagnostics as structs:

```elixir
{:ok, _build, diagnostics} = Cherry.check(source: "site")

for d <- diagnostics, d.severity == :error do
  {d.rule, d.file, d.message}
end
```

Once the build is a value and the diagnostics are structs, a few pleasant patterns fall out.

## Where the library lane earns its keep

**A test that keeps your site honest.** Drop this in any mix project that carries a Cherry site and your content is gated by `mix test` like everything else:

```elixir
test "the site builds clean" do
  assert {:ok, _build, []} = Cherry.check(source: "site")
end
```

This very pattern is how cherrybomb.dev works: the site you are reading is the `example/` directory of Cherry's own repository, and a test asserts it builds with feeds, icons, and a clean strict check on every commit. The framework cannot drift from its own instructions, because the instructions are executable.

**Content from data.** The content tree is plain files, so generating it is just Elixir. A hundred markdown files from a changelog, release notes from git tags, a page per package in your umbrella:

```elixir
for %{name: name, desc: desc} <- packages do
  File.write!("site/content/pages/packages/#{name}.md", """
  ---
  title: #{name}
  description: #{desc}
  ---
  #{long_form(name)}
  """)
end

{:ok, _build} = Cherry.build(source: "site", output: "_site")
```

Determinism makes this loop trustworthy: regenerate everything, rebuild, and the diff shows exactly what your data change changed, nothing else.

**Docs beside an application.** An umbrella app can grow a `site/` directory and a `mix cherry.serve` away from documentation with live reload, no Node toolchain arriving in a BEAM shop's dependency tree. When the docs deploy, it is the same `_site/` artifact as any Cherry site, and your existing CI builds it with `mix cherry.build` using the Elixir you already have.

**Scripting against structured output.** Everything the CLI prints as JSON exists as data one function call away, so tooling composes without parsing anything:

```elixir
{:ok, _build, diagnostics} = Cherry.check(source: "site")

diagnostics
|> Enum.frequencies_by(& &1.rule)
#=> %{"missing-description" => 3, "broken-link" => 1}
```

## When to stay with the binary

No Elixir on the machine, CI that should stay toolchain-free, or a writer's laptop you will never install a toolchain on: the binary is the right lane, and `AGENTS.md` plus the JSON envelopes mean even an agent-driven workflow never needs the package. Moving between lanes later costs nothing; the site directory is identical either way.

The [Elixir guide](/guides/elixir/) has the full task table and the `cherry_new` scaffold; [hexdocs.pm/cherry](https://hexdocs.pm/cherry) has the API. And if you are curious what the long-lived half of Cherry looks like (the dev server is the one place we run a supervision tree), that is [the next post](/the-embedded-server/).
