---
title: Content components
description: Figures, privacy-preserving video embeds, and callouts, as markdown directives.
---
## Content components

Markdown is deliberately boring, so the things markdown is bad at are directives: a syntax Docusaurus and VitePress writers already know, expanded by the framework before the markdown pass. Framework-level means they are theme-independent: swap themes and every figure, video, and callout still renders, styled by the new theme's tokens.

### Figure

```text
::figure{src="/images/nif-boundary.svg" alt="The NIF boundary" caption="Where the BEAM ends and Rust begins."}
```

Emits a semantic `<figure>` with `<figcaption>`. `alt` is required: leaving it off is a `component` diagnostic in `cherry check`, because alt text is not optional. Root-absolute `src` paths pick up the site's `base_path`, which raw `<img>` HTML in markdown never does; deploy under `/repo/` and component images just work.

Here is one, live:

::figure{src="/brand/cherrybomb-mark.webp" alt="The CherryBomb mascot: two cherries with a lit fuse and sunglasses" caption="A figure rendered by the component you just read about."}

### Video

```text
::video{youtube="q6Yr9DkTn2k" title="Backpressure in practice"}
```

The YouTube form renders a **facade**: a styled link with a play button that makes zero third-party requests at page load. Click it and a tiny island (about 500 bytes) swaps in a `youtube-nocookie.com` iframe. Without JavaScript the link simply goes to YouTube. Your readers are never tracked for a video they did not play.

```text
::video{src="/videos/demo.mp4" poster="/images/demo-poster.jpg" title="The demo"}
```

The local form emits a native `<video controls preload="metadata">` player. `poster` is optional and `base_path`-aware like every component path.

### Callouts

```text
:::tip{title="Rule of thumb"}
Size the queue for the promise, not the traffic.
:::
```

:::tip{title="Rule of thumb"}
Size the queue for the promise, not the traffic. This callout is rendered by the component above it.
:::

Five types, matching GitHub's alert vocabulary: `note`, `tip`, `important`, `warning`, `caution`. The `title` is optional and defaults to the type name. Callouts nest markdown: lists, code, links all work inside.

### Misuse is a diagnostic, never a broken build

A directive with a problem stays visible in the output exactly as you typed it, and `cherry check` names it precisely:

```text
[error] content/posts/2026-01-01-clip.md: component — ::figure needs alt — alt text is not optional
```

Two more properties worth knowing:

- **Fences shield.** A directive inside a code block is shown, not expanded, which is how this page documents the syntax.
- **Attribute values cannot contain double quotes.** Use `&quot;` entities or restructure; the parser refuses ambiguity rather than guessing.
