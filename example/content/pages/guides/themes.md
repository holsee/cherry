---
title: Themes, tokens, and drift
description: Two official themes, a token styling API, ejects that carry provenance, and theme.diff. How Cherry keeps custom looks upgradeable.
---
# Themes, tokens, and drift

Octopress froze every customized blog in time: hand-copied theme files that could never take an upstream fix again. Cherry's theme system exists to kill that failure mode.

## Pick a theme

```elixir
# cherry.exs
theme: "cherrybomb"
```

Two ship built-in: `default` (typography-first, Charter serif, quiet) and `cherrybomb` (the brand: neon night wall by dark, poster paper by day, and the one this site wears). Inspect any theme's full API:

```sh
cherry theme.list
```

The output names every template, its assigns, and the important part: the **tokens**, CSS custom properties like `--color-accent` and `--font-prose` with documented meanings. Tokens are the styling API.

## Restyle without forking

Most customization is a token override, not a template edit. Drop a file in `static/` that redefines tokens after the theme's stylesheet, and the whole world (code blocks included) follows your palette in both light and dark renditions.

## Take ownership of a template

When you need different markup, eject exactly the template you want to own:

```sh
cherry theme.eject post
```

The copy lands in `themes/cherrybomb/templates/post.html.eex` **with a provenance header** recording which theme version and content hash it came from. That header is not decoration; it's what makes upgrades mergeable.

> [!WARNING]
> Never hand-copy a theme file. A copy without provenance is `untracked` drift: `cherry check` will warn, and `theme.diff` can't help you merge upstream changes.

## Survive upgrades

After upgrading Cherry, ask where your overlays stand:

```sh
cherry theme.diff
```

Every overlay gets a three-way status against the installed theme:

- `current`: upstream unchanged; nothing to do.
- `auto_updatable`: upstream moved, your copy untouched. Run `theme.diff --apply` to re-eject with fresh provenance.
- `conflict`: both moved. Merge by hand, then `theme.eject post --force` to re-stamp.
- `untracked`: no provenance header; re-eject to adopt it into the managed flow.

## Fork the whole world

```sh
cherry gen.theme neon --from cherrybomb
```

That scaffolds a complete site-local theme (manifest, templates, tokens) as a starting point that's yours outright. Same contract, so `check` and every pipeline stage treat it exactly like an official theme.
