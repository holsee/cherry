---
title: Restyle without forking
description: Token overrides from one command, custom.css that always wins, ejects that carry provenance, and theme.diff. How Cherry keeps custom looks upgradeable.
---
# Restyle without forking

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

Most customization is a token override, not a template edit. Start by asking what the theme exposes:

```sh
cherry theme.tokens
```

Every token, its default, what it does, and any override you already have. Overriding one is a config write:

```sh
cherry config tokens.--color-accent "#7c3aed"
```

That lands as `tokens: ["--color-accent": "#7c3aed"]` in `cherry.exs`, and the whole world (code blocks included) follows your palette. The name is validated against the theme's manifest, so a typo is refused with the nearest real token named instead of becoming a dead line in your config. A value applies to both renditions unless you write it as `light-dark(a, b)`.

When a token is not enough, `assets/custom.css` is the pressure valve: it loads after everything else, always. Theme CSS lives inside `@layer theme` and your overrides are unlayered, so yours win by declaration: no `!important`, no specificity fights.

## Take ownership of a template

When you need different markup, eject exactly the template you want to own:

```sh
cherry theme.eject post
```

The copy lands in `themes/cherrybomb/templates/post.html.eex` **with a provenance header** recording which theme version and content hash it came from. That header is not decoration; it's what makes upgrades mergeable.

You can also skip the eject and write the overlay fresh, in either language: drop a `post.html.heex` beside (or instead of) the `.eex` and it wins the lookup, with escaping by default and compile-checked markup. `cherry theme.which post` always shows which file renders. The full two-language story is in [the theming docs](/docs/theming/).

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
- `rewritten`: you rewrote it in HEEx. Another language, yours outright; no merge exists or is expected.
- `shadowed`: an `.eex` copy sitting under a `.heex` rewrite. It no longer renders, and the report says so instead of calling it current.

## Fork the whole world

```sh
cherry gen.theme neon --from cherrybomb
```

That scaffolds a complete site-local theme (manifest, templates, tokens) as a starting point that's yours outright. Same contract, so `check` and every pipeline stage treat it exactly like an official theme. [Create a theme](/guides/creating-a-theme/) walks the whole rung, HEEx components included.
