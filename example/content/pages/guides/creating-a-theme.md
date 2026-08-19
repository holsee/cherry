---
title: Create a theme
description: Scaffold a theme of your own from an official one, retune its tokens, restyle it, and rewrite a template in HEEx.
---
# Create a theme

The [styling ladder](/docs/theming/) exists so you rarely need this guide: tokens and `custom.css` cover most restyles for a config line and a stylesheet. This guide is for the top rung, where the design is yours end to end: a theme with your name on it, still upgrade-safe, still contract-checked. We will build one called `neon`.

## 1 · Scaffold from an official theme

```text
$ cherry gen.theme neon --from cherrybomb
Created themes/neon — set `theme: "themes/neon"` in cherry.exs and edit away; the contract keeps the site building.

$ cherry config theme themes/neon
theme: cherrybomb → themes/neon (written to cherry.exs)
```

Two commands, no file editing. Your site now renders through `themes/neon/`, a complete copy you own:

```text
themes/neon/
├── theme.exs            # the manifest: identity, templates, tokens
├── assets/
│   ├── site.css         # every color flows through the tokens
│   └── *.js             # the islands: theme toggle, copy buttons, video facade
└── templates/           # nine templates, EEx
```

The contract is the safety net. Nine templates with declared assigns, a token manifest, one stylesheet: as long as those exist, `cherry build` keeps working, and the verifier tells you precisely what is missing if you delete too enthusiastically.

## 2 · The manifest is the API

`theme.exs` declares what your theme promises. The interesting half is the token manifest, because it is what `cherry theme.tokens` prints and what `tokens:` overrides are validated against:

```elixir
tokens: [
  "--color-bg": [
    default: "#fbf6f8",
    dark: "#14090f",
    doc: "Page background (poster paper by day, the wall at night)."
  ],
  "--color-accent": [
    default: "#c0134f",
    dark: "#ff4d7d",
    doc: "The hot pink: links, title stroke, glow."
  ],
  "--font-prose": [
    default: "system-ui, 'Segoe UI', Roboto, sans-serif",
    doc: "Reading face (system stack, zero bytes)."
  ],
  # ...
]
```

`default:` is the light value, `dark:` the dark half of the pair; a token without `dark:` is rendition-independent. Retune these first: for a lot of themes, new colors and new faces are already the whole redesign. Anyone using your theme gets the same override ladder you get from the official ones, documentation included, because the manifest is the documentation.

## 3 · The stylesheet

`assets/site.css` is yours to rewrite, with two conventions worth keeping:

- **Every color through a token.** The stylesheet says `var(--color-accent)`, never a hex. That is what makes `light-dark()` pairs, user overrides, and clean printing all work without further thought.
- **Keep the `@layer theme` wrapper.** Site `custom.css` is unlayered, so it beats your theme by cascade-layer rules rather than specificity wars. Your users will thank you.

Change values in the manifest, shapes in the CSS. The live-reloading `cherry serve` makes this loop immediate.

## 4 · Templates, in either language

The nine templates are EEx, and you can edit them as they are. But a theme of your own is also the natural place for the HEEx lane: delete a template's `.eex` and write the `.heex`, or keep both and let the extension decide, since `.heex` outranks `.eex` at the same level:

```text
$ cherry theme.which post_list
post_list:
  theme  themes/neon/templates/post_list.html.heex ← renders
  theme  themes/neon/templates/post_list.html.eex
  ...
```

HEEx buys you escaping by default, compile-checked markup (a malformed template fails the build with file, line:column, and a caret), and function components. Declare those in a `components.exs` at the theme root:

```elixir
defmodule Neon.Components do
  use Phoenix.Component

  attr :title, :string, required: true
  slot :inner_block

  def card(assigns) do
    ~H"""
    <section class="card"><h2>{@title}</h2>{render_slot(@inner_block)}</section>
    """
  end
end
```

and use them in any of the theme's HEEx templates the way a Phoenix developer expects:

```heex
<.card title={@doc.meta.title}>
  {raw(@doc.html)}
</.card>
```

It is runtime-compiled like every other `.exs` escape hatch, so the standalone binary renders it identically to a mix project. No build step appears anywhere in this guide, and none will.

## 5 · Verify the whole thing

```text
$ cherry check --strict
Checked 34 page(s): all clear.
```

The verifier covers your theme too: templates that link to routes the build does not emit, images without alt text in your markup, drift in anything you ejected on top. And because [builds are deterministic](/docs/pipeline/), a theme change shows up in the output diff as exactly what it is, nothing more.

:::note{title="Sharing a theme"}
A theme is a directory. Publish it as a git repo and users copy it into `themes/` and point `theme:` at it; the contract check tells them immediately if their Cherry is too old for your manifest. A registry lane may come later; the directory will keep working either way.
:::
