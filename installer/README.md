# cherry_new

Project generator for [Cherry](https://hex.pm/packages/cherry), the static
site generator for hackers.

```sh
mix archive.install hex cherry_new
mix cherry.new mysite
```

The scaffold is a complete, buildable site: typed content directories, a
`cherry.exs` config, a first post, a GitHub Pages deploy workflow, and an
`AGENTS.md` describing the publish loop for any coding agent helping run
the site. The generated `mix.exs` depends on the cherry release that
matches this installer.

```sh
cd mysite
mix cherry.serve            # live-reloading dev server
mix cherry.build            # → _site/, plain files, host anywhere
mix cherry.check --strict   # the verifier
```

Prefer no Elixir toolchain at all? Install the standalone binary instead:
see the [quick-start](https://cherrybomb.dev/guides/quick-start/).

Docs: [hexdocs.pm/cherry](https://hexdocs.pm/cherry) · Site:
[cherrybomb.dev](https://cherrybomb.dev) · Source:
[github.com/holsee/cherry](https://github.com/holsee/cherry)
