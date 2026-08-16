# Juno Vale — Cherry demo site

A complete, fictional Cherry site: a blog with six posts, a portfolio timeline,
a CV-tagged work history, an ejected theme template, and search that needs no
Node.

**Every file here was produced by following [../GUIDE.md](../GUIDE.md).** The
guide is the source; this directory is the result. If you change one, change
the other.

Juno Vale is invented. So is Ledgerbeam, and every URL under
`junovale.example` — `.example` is reserved by the IETF and resolves nowhere,
which is what makes it safe to put in a demo.

## Running it

From the root of this repository:

```
mix cherry.build --source demo/site     # → demo/site/_site
mix cherry.check --source demo/site --strict
mix cherry.serve --source demo/site --port 0
```

With the standalone binary, from inside this directory, the same three are
`cherry build`, `cherry check --strict`, and `cherry serve`.

## What it does not have

A `mix.exs` and a `config/` directory. A site scaffolded by `cherry new` has
both, so it can carry its own Cherry dependency. This one is built by the
Cherry checkout it lives in, so they would be redundant. Nothing else differs.
