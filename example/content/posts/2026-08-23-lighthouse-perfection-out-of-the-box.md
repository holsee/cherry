---
title: "Lighthouse perfection out of the box"
description: Perfect Lighthouse scores for performance, accessibility, best practices and SEO, plus a full agentic-browsing pass - and why a Cherry site gets all five without configuring anything.
tags: [design, performance, seo, agents]
---

<svg viewBox="0 0 980 260" role="img" aria-label="Lighthouse scores for a Cherry site: 100 for Performance, Accessibility, Best Practices and SEO, and a 3/3 agentic browsing pass" style="width: 100%; height: auto; display: block; font-family: var(--font-mono);">
  <g fill="none" stroke="var(--color-accent)" stroke-width="4" style="filter: drop-shadow(0 0 9px color-mix(in srgb, var(--color-accent) 65%, transparent));">
    <circle cx="130" cy="106" r="46" fill="var(--color-accent)" fill-opacity="0.08"/>
    <circle cx="310" cy="106" r="46" fill="var(--color-accent)" fill-opacity="0.08"/>
    <circle cx="490" cy="106" r="46" fill="var(--color-accent)" fill-opacity="0.08"/>
    <circle cx="670" cy="106" r="46" fill="var(--color-accent)" fill-opacity="0.08"/>
    <rect x="791" y="86" width="118" height="40" rx="20" stroke-width="1.5" fill="var(--color-surface)"/>
  </g>
  <g fill="var(--color-accent)" font-size="27" font-weight="600" text-anchor="middle">
    <text x="130" y="115">100</text>
    <text x="310" y="115">100</text>
    <text x="490" y="115">100</text>
    <text x="670" y="115">100</text>
    <circle cx="817" cy="106" r="7" style="filter: drop-shadow(0 0 5px var(--color-accent));"/>
    <text x="860" y="113" font-size="20">3/3</text>
  </g>
  <g fill="var(--color-fg)" font-size="15.5" font-weight="600" text-anchor="middle">
    <text x="130" y="188">Performance</text>
    <text x="310" y="188">Accessibility</text>
    <text x="490" y="188">Best</text>
    <text x="490" y="210">Practices</text>
    <text x="670" y="188">SEO</text>
    <text x="850" y="188">Agentic</text>
    <text x="850" y="210">Browsing</text>
  </g>
  <g>
    <circle cx="870" cy="30" r="3" fill="var(--color-accent)" fill-opacity="0.75"/>
    <circle cx="900" cy="48" r="3" fill="#eec06e" fill-opacity="0.65"/>
    <circle cx="845" cy="59" r="3" fill="#96beff" fill-opacity="0.55"/>
    <circle cx="925" cy="40" r="3" fill="#78dcb4" fill-opacity="0.5"/>
    <circle cx="945" cy="75" r="3" fill="var(--color-accent-strong)" fill-opacity="0.65"/>
    <circle cx="905" cy="152" r="3" fill="#be8cff" fill-opacity="0.55"/>
    <circle cx="875" cy="230" r="3" fill="var(--color-accent)" fill-opacity="0.5"/>
    <circle cx="935" cy="130" r="3" fill="var(--color-accent)" fill-opacity="0.55"/>
    <circle cx="955" cy="200" r="3" fill="#96beff" fill-opacity="0.45"/>
    <circle cx="915" cy="222" r="3" fill="#eec06e" fill-opacity="0.5"/>
    <circle cx="890" cy="12" r="3" fill="#be8cff" fill-opacity="0.5"/>
    <circle cx="948" cy="18" r="3" fill="var(--color-accent)" fill-opacity="0.45"/>
    <circle cx="300" cy="24" r="3" fill="var(--color-accent)" fill-opacity="0.22"/>
    <circle cx="520" cy="238" r="3" fill="#eec06e" fill-opacity="0.2"/>
    <circle cx="120" cy="226" r="3" fill="#96beff" fill-opacity="0.18"/>
    <circle cx="700" cy="16" r="3" fill="#be8cff" fill-opacity="0.18"/>
    <circle cx="60" cy="52" r="3" fill="var(--color-accent)" fill-opacity="0.18"/>
    <circle cx="620" cy="228" r="3" fill="#78dcb4" fill-opacity="0.16"/>
  </g>
</svg>

:::tip{title="TL;DR"}
Run Lighthouse against a Cherry site wearing any of the thirty official
themes and it comes back 100, 100, 100, 100, with the agentic-browsing
checks passing 3/3. None of that is tuning, and none of it belongs to
the theme. The framework owns the parts a theme could get wrong - the
SEO head, font loading, the machine surface - and `cherry check` gates
the rest, so every site starts at the ceiling and the only way to leave
it is to opt out.
:::

Scores like this are usually the end of a story: an audit, a backlog of
fixes, a week of chasing tenths. On a Cherry site they are the starting
state - and not for one blessed default, but for every one of the
thirty official themes, from the CSS-only ones to the WebGL ones. This
post walks through each of the five lights and shows where in the
framework the work actually lives, because none of it lives in your
site or your theme.

## Performance: ship nothing, then ship it well

The fastest request is the one the page never makes. A Cherry build is
plain HTML and one stylesheet; there is no client framework, no hydration
bundle, no analytics snippet, and no third-party request of any kind.
Themes that want motion mount it as small, deferred islands - a canvas
here, a search index there - so the reading path never waits on script.

What does load is engineered around the paint:

- **Fonts land before first paint.** Every face a theme ships is a
  self-hosted, latin-subset woff2, preloaded from the framework-owned
  head. Each family carries a metric-matched local fallback -
  `size-adjust`, ascent, descent and line-gap measured against the real
  face - so even when a slow connection delivers the font late, the swap
  moves nothing. That is where the layout-shift score comes from: the
  page simply has no reason to reflow.
- **Decoration never blocks layout.** Theme atmospherics paint to
  `position: fixed` canvases behind the page or arrive inside the
  existing box. First paint is the finished layout.
- **Builds are deterministic.** Same tree in, same bytes out. There is
  no runtime doing work per request that the build could have done once.

## Accessibility: the templates are the audit

The score is a consequence of the theme contract, not a checklist run
after the fact. Official templates use semantic landmarks (`header`,
`main`, `nav`, `article`), label their controls (the theme toggle and
copy buttons are `aria-label`led icon buttons), keep focus visible, and
honour `prefers-reduced-motion` in every animated theme - reduced motion
means one still frame, not a slightly slower animation. Colour flows
through the token system in both renditions, so contrast is a property
of the palette, and every one of the thirty themes ships a light and a
dark rendition that hold it.

## Best practices: boring on purpose

No console errors, no deprecated APIs, no mixed content, no third-party
origins to leak to. Everything a page references lives on your own
domain, from fonts to search. Images carry real `width` and `height`
attributes. JS-off is a designed state, not an accident: every island
has an honest static fallback, and print gets its own consideration.
The audit has nothing to find because the surface area is small and
self-contained.

## SEO: the head your theme cannot forget

The classic SEO failure is not a missing technique, it is a missing tag.
Cherry makes that structural: the SEO head is framework-owned HTML that
every theme renders as a single assign, or fails the contract check. So
every page - on every theme, with zero config - carries its canonical
URL, description, Open Graph and Twitter cards, feed links (Atom and
JSON Feed), favicons, and JSON-LD where it applies (a `Person` on the
portfolio, `BlogPosting` on posts). `robots.txt` and `sitemap.xml` are
build outputs. Root-relative links respect `base_path`, so project-pages
deployments do not bleed 404s into the index.

And the part audits cannot see: `cherry check` refuses a build with a
broken internal link, and the deploy workflow runs the same check before
it builds. A link that would rot your crawl budget never reaches
production. The full story is in [LLMs and SEO](/llms-and-seo/).

## Agentic browsing: the third audience

The newest column on that scorecard measures what the other four ignore:
can a machine that is not a crawler actually use the site? Cherry passes
all three checks because the machine surface is a build output, not an
afterthought:

1. **A table of contents for language models.** Every build emits
   [`/llms.txt`](/llms.txt), the curated map of what the site contains
   and where.
2. **A plain mirror of every page.** Beside each `index.html` sits an
   `index.md` - the page as the author wrote it, not as the theme
   rendered it. An agent curls it and gets clean markdown, no DOM
   parsing, no readability heuristics.
3. **Structured data for everything that has structure.** JSON Feed for
   the blog, a `cv.json` JSON Resume on sites with a profile, and the
   search index as plain JSON.

The same philosophy runs through the CLI: every verb takes `--json` and
returns one envelope shape with honest exit codes, so the agent editing
your site works the same interface as the agent reading it. That half is
documented in [the machine surface](/docs/machine-surface/).

## Out of the box means out of the box

Here is the part that matters if you are choosing a tool rather than
admiring a scorecard. Nothing above is a plugin, a recipe, or a config
flag. It is what `cherry new` hands you:

- the SEO head, feeds, sitemap and robots - emitted for every site;
- font preloading and metric-matched fallbacks - part of every official
  theme, enforced by the same conformance tests;
- the machine surface - `llms.txt`, markdown mirrors, JSON everywhere -
  emitted for every build;
- the link gate - `cherry check` in your terminal and in the deploy
  workflow `cherry gen.action` writes for you.

Swap any of the [thirty themes](/themes/) and the scores do not move,
because the score-bearing parts never belonged to the theme. That is
the design: the framework owns what must never regress, the theme owns
the personality, and you own the content. Lighthouse just confirms the
division of labour.
