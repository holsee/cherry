---
title: Pages and the landing page
description: Static pages from plain markdown files, and a landing page with a hero built from raw HTML, theme classes, and custom.css.
---
# Pages and the landing page

A page is one markdown file in `content/pages/`, and the home page is just the page called `index.md`. This guide adds a static page, then turns the scaffold's home page into a proper landing page with a hero - the same technique this site's own [landing page](/) uses.

## Add a page

Write a file; the filename is the URL. `content/pages/now.md`:

```markdown
---
title: Now
description: What I am working on right now.
---
## Now

Pressing apples, mostly.
```

Save it and the page is live at `/now/` (with `cherry serve` running, it is in your browser before you switch windows). `about.md` is `/about/`, nested directories nest the URL, and a `permalink:` in the frontmatter overrides the derived route when a section index wants a clean URL:

```yaml
---
title: Docs
permalink: /docs/
---
```

Every page gets a body class from its route - `/now/` renders `<body class="page-now">` - so page-specific CSS has a stable hook without touching templates.

> [!NOTE]
> `title` and `description` are required by convention, not ceremony: the description feeds search snippets and social cards, and `cherry check --strict` flags a page without one.

## The home page is index.md

`cherry new` scaffolds it like any other page:

```markdown
---
title: Home
description: Junovale, grown with Cherry.
---
# Junovale

Fresh from `cherry new`. Edit `content/pages/index.md` to make
this page yours.
```

It renders at `/` with `<body class="page-home">`. Editing this file is the whole job of making a landing page; the rest of the guide is about making it look like one.

## Raw HTML when markdown runs out

Markdown passes raw HTML through untouched, so a landing page mixes the two: HTML for layout you want to control, markdown for everything else. A hero, in `content/pages/index.md`:

```markdown
---
title: Home
description: Juno Vale, systems engineering notes from the orchard.
---
<section class="hero">
<h1>Juno Vale</h1>
<p class="hero-tagline">Systems engineering notes from the orchard: Elixir, presses, and the occasional outage story.</p>
<p class="hero-actions"><a class="button" href="/blog/">Read the blog</a> <a class="button button-ghost" href="/cv/">CV</a></p>
</section>

## Latest from the press

Markdown keeps working between the HTML sections, so the rest of the
page is ordinary writing.
```

The HTML lands in the output exactly as written, wrapped in the theme's layout like any other page. Markdown between the sections keeps working, [content components](/docs/components/) included.

## Style it

Two lanes, matching the [customisation ladder](/guides/themes/):

**The cherrybomb theme ships landing classes.** The classes in the hero above - `hero`, `hero-tagline`, `hero-actions`, `button`, `button-ghost`, plus `cmd` for copyable install lines and `checks` for a feature list - are part of the cherrybomb theme's stylesheet, the same ones this site's landing page uses. One command switches a site onto it:

```sh
cherry config theme cherrybomb
```

```text
theme: default → cherrybomb (written to cherry.exs)
```

**Any theme takes your own CSS.** On the default theme (or your own), style the same HTML in `assets/custom.css`, which loads last and always wins:

```css
.hero {
  text-align: center;
  padding-block: 3rem 2rem;
}

.hero-tagline {
  font-size: 1.2rem;
  max-width: 38ch;
  margin-inline: auto;
  color: color-mix(in srgb, var(--color-fg) 75%, transparent);
}
```

Theme tokens (`var(--color-fg)`, `var(--color-accent)`, and friends - `cherry theme.tokens` lists them all) keep your CSS correct in light and dark without writing either twice. The [theming reference](/docs/theming/) covers the full token API.

## Keep it in the loop

A landing page is a page: the verifier builds it, walks its links, and holds it to the same rules as every post:

```sh
cherry check --strict
```

```text
Checked 33 page(s): all clear.
```

From here: the [content model](/docs/content/) is the reference for pages and their frontmatter, [restyle without forking](/guides/themes/) climbs the rest of the styling ladder, and if the landing page has outgrown restyling, [create a theme](/guides/creating-a-theme/) of your own.
