---
title: Theming
description: The styling ladder, design tokens, light-dark pairs, overlays, provenance, and the HEEx lane.
---
## Theming

Two convictions shape everything on this page. First, restyling a site should cost exactly as much ownership as you choose to take, never a fork. Second, whatever you do take ownership of should stay upgradeable, with the tool telling you the truth about what you own. Cherry ships thirty official themes (from `default`, typography-first and quiet, and `cherrybomb`, the one you are reading, through CSS-only restyles like `porcelain`, `teletype`, `halftone` and `broadsheet`, to canvas and WebGL worlds like `prism`, `constellation`, `warp` and `showoff`; the [gallery](/themes/) shows every one, and each links to a "Using" page with that theme's full token API) built from the same parts: a `theme.exs` manifest, a declared template inventory, one stylesheet whose every colour flows through tokens.

### The ladder

<div class="diagram" role="img" aria-label="The five rungs of the styling ladder, each costing more ownership: tokens, custom.css, overlay, eject, new theme.">
<svg viewBox="0 0 720 250" xmlns="http://www.w3.org/2000/svg" style="font-family: var(--font-mono); font-size: 13px;">
  <g fill="var(--color-surface)" stroke="var(--color-border)">
    <rect x="10"  y="190" width="128" height="40" rx="8"/>
    <rect x="152" y="150" width="128" height="80" rx="8"/>
    <rect x="294" y="110" width="128" height="120" rx="8"/>
    <rect x="436" y="70"  width="128" height="160" rx="8"/>
    <rect x="578" y="30"  width="128" height="200" rx="8" stroke="var(--color-accent)"/>
  </g>
  <g fill="var(--color-fg)" text-anchor="middle">
    <text x="74"  y="214">tokens</text>
    <text x="216" y="174">custom.css</text>
    <text x="358" y="134">overlay</text>
    <text x="500" y="94">eject</text>
    <text x="642" y="54" fill="var(--color-accent)">new theme</text>
  </g>
  <g fill="var(--color-muted)" font-size="11px" text-anchor="middle">
    <text x="74"  y="230">one config line</text>
    <text x="216" y="190">one CSS file</text>
    <text x="358" y="150">one template</text>
    <text x="500" y="110">that file's future</text>
    <text x="642" y="70">everything, deliberately</text>
    <text x="360" y="16" font-size="12px">ownership you take on →</text>
  </g>
</svg>
</div>

**Rung 1: tokens.** Every theme publishes its tokens as an API. List them, then override from config or the CLI:

```text
$ cherry theme.tokens
tokens of theme default:
  --color-bg             light-dark(#ffffff, #15171b)
                         Page background.
  --color-accent         light-dark(#b3173e, #f4718c)
                         Links and interactive accents.
  ...

$ cherry config tokens.--color-accent "light-dark(#7c3aed, #a78bfa)"
```

The override lands in every page head, the 404 included. A typo is an error with a suggestion, not a silently dead line. After the write, `theme.tokens` shows the merged view:

```text
  --color-accent         light-dark(#7c3aed, #a78bfa) (override; default #b3173e)
```

**Rung 2: custom.css.** Drop `assets/custom.css` in your site and it links after the tokens block on every page. Official theme CSS lives in a `theme` cascade layer, so your unlayered rules always win: no specificity fights, no `!important`.

**Rung 3: overlay.** Write one template into `themes/THEME/templates/` and it shadows just that template, in EEx or HEEx, your choice.

**Rung 4: eject.** `cherry theme.eject post_list` copies the original into your overlay directory with a provenance header (theme, version, content hash). Now it is yours, and upgrades stay mergeable; see provenance below.

**Rung 5: a theme of your own.** `cherry gen.theme neon --from cherrybomb` scaffolds the complete theme into `themes/neon/`: manifest, templates, stylesheet, islands. The [theme guide](/guides/creating-a-theme/) walks the whole rung.

### Light and dark are one value

Every color token in an official theme is a `light-dark()` pair: the light value and the dark value in one declaration, picked by the browser's `color-scheme`. The consequences are pleasant everywhere:

- The theme toggle flips a single `color-scheme` property. No duplicate stylesheets, no class soup, no flash.
- Your overrides carry both renditions in one line, or one value for both.
- Print always gets the complete light rendition, even from a page forced dark, syntax highlighting included.
- Engines without `light-dark()` support get the full light rendition as a fallback, never broken colours.

### The lookup chain

When Cherry renders a page it looks for the template in three places, most specific first, and in two languages per level. The first file that exists renders; `theme.which` shows you exactly which:

```text
$ cherry theme.which post_list
post_list:
  site_overlay  themes/default/templates/post_list.html.heex ← renders
  site_overlay  themes/default/templates/post_list.html.eex
  theme         priv/themes/default/templates/post_list.html.heex (missing)
  theme         priv/themes/default/templates/post_list.html.eex
  framework     priv/themes/default/templates/post_list.html.heex (missing)
  framework     priv/themes/default/templates/post_list.html.eex
```

### Inheriting templates (contract 1.1)

A theme does not have to ship templates at all. Declare the full inventory in the manifest as usual, add `inherit_templates: true`, and any template file the theme does not ship resolves through the framework level - the default theme's copy renders. `theme.list` reports those templates as `inherited (framework)`.

That makes a CSS-only theme real: a `theme.exs`, a `site.css`, and the fonts it self-hosts. Nothing copied means nothing to drift. The moment you want your own markup for one template, ship just that file; it wins over the inherited copy, and the rest keep falling through.

Fonts load without a flash. Every `.woff2` a theme ships under `assets/fonts/` is preloaded from the framework-owned head of every page, so the fetch starts with the HTML rather than after the stylesheet is parsed; the official themes declare `font-display: block` (one paint, in the right face) and pair each family with a metric-matched local fallback (`"Geist Fallback"`, `size-adjust` and the ascent, descent and line-gap overrides computed from the font) so the rare swap after a slow fetch moves nothing. A theme of your own gets the preloads for free; the fallback faces are a pattern to copy.

`gen.theme --from` on an inheriting theme copies the resolved templates into your fork, so forks stay self-contained and editable.

### Theme islands, and tokens beyond CSS

A theme may ship behaviour as well as style: its `assets/*.js` files are its islands, included from its own layout template exactly like the official copy button and theme toggle. The conventions that keep them honest: built and self-hosted (no CDN scripts, zero third-party requests), lazy where heavy, frozen to their first frame under `prefers-reduced-motion`, and the page must be complete without them.

Islands read the theme's tokens instead of carrying their own colours - the **token to uniform bridge**. Paint the token onto a probe element and let the browser resolve it (hex, `light-dark()`, `color-mix()` all included), then hand the rgb to your canvas or shader:

```js title="the bridge, in full"
const probe = document.createElement("div");
probe.style.display = "none";
document.body.appendChild(probe);

function tokenRGB(name) {
  probe.style.color = `var(${name})`;
  const [r, g, b] = getComputedStyle(probe).color.match(/[\d.]+/g);
  return [r / 255, g / 255, b / 255];
}

// Re-read when the rendition changes: the toggle writes [data-theme],
// the OS flips prefers-color-scheme.
new MutationObserver(reload).observe(document.documentElement, {
  attributes: true, attributeFilter: ["data-theme"],
});
matchMedia("(prefers-color-scheme: dark)").addEventListener("change", reload);
```

This is how the prism theme's WebGL mesh follows `cherry config tokens.--color-accent` like any link would: the shader's uniforms come from the same API the stylesheet reads.

### Two template languages

EEx or HEEx is not a configuration choice; it is a file extension, and `.heex` outranks `.eex` at the same level. Official themes are EEx. The HEEx lane is for overlays, rewrites, and themes of your own, and it brings the full Phoenix feel:

- Interpolation escapes by default; `raw(@doc.html)` is the explicit door for rendered markdown.
- `:for` and `:if` attributes, and compile-checked markup: a malformed template fails the build with file, line:column, and a caret.
- **Function components.** Drop a `components.exs` in your theme defining modules with `use Phoenix.Component`, and `<.card title={@title}>` resolves in that theme's templates the way a Phoenix developer expects. It is runtime-compiled like every other `.exs` escape hatch, so the standalone binary renders it identically to a mix project.

### Provenance, kept honest

`theme.diff` reports the state of every template you have taken:

```text
$ cherry theme.diff
default 0.1.0 overlays:
  post_list            rewritten
  post_list            shadowed — the .heex rewrite renders; this file is inert
```

| status | meaning |
|---|---|
| `current` | your copy matches the theme version it came from |
| `auto_updatable` | upstream moved, you did not touch it; `--apply` re-ejects safely |
| `conflict` | both moved; resolve by hand, then `theme.eject --force` |
| `untracked` | a hand copy with no provenance header, which nothing can manage |
| `rewritten` | a `.heex` rewrite: another language, yours outright |
| `shadowed` | an `.eex` copy a `.heex` rewrite outranks; it no longer renders |

The tool refuses to help you fool yourself. Eject a template that you have already rewritten in HEEx and it declines, naming the file to edit instead:

```text
$ cherry theme.eject post_list
error: post_list is rewritten as HEEx at themes/default/templates/post_list.html.heex,
which wins the lookup — an ejected EEx copy would be shadowed; edit the .heex file
```

:::important{title="Never hand-copy a theme file"}
The provenance header is what lets `theme.diff` three-way-merge upgrades later. A hand copy reports as `untracked`, and from there Cherry can only warn.
:::
