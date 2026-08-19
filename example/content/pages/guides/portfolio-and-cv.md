---
title: Build a portfolio and host your CV
description: From an empty site to a developer timeline, story pages, and a print-ready CV with JSON Resume output.
---
# Build a portfolio and host your CV

By the end of this guide you will have a portfolio timeline at `/portfolio/`, story pages that cross-link your work by tag, and a CV at `/cv/` that prints to a clean one-pager and ships a machine-readable `cv.json`. All from markdown files, all checked by the verifier, all on your own domain.

It builds on [your first site](/guides/quick-start/); any Cherry site works as the starting point.

## How the pieces fit

You write entries into five collections. Cherry renders three surfaces from them, and the `cv:` block in each entry decides what the third one shows:

<div class="diagram" role="img" aria-label="Five collections (positions, projects, talks, oss, education) flow into three surfaces: the timeline, story pages, and the CV. The cv block gates the CV.">
<svg viewBox="0 0 720 220" xmlns="http://www.w3.org/2000/svg" style="font-family: var(--font-mono); font-size: 13px;">
  <g fill="var(--color-surface)" stroke="var(--color-border)">
    <rect x="10" y="14"  width="170" height="34" rx="8"/>
    <rect x="10" y="56"  width="170" height="34" rx="8"/>
    <rect x="10" y="98"  width="170" height="34" rx="8"/>
    <rect x="10" y="140" width="170" height="34" rx="8"/>
    <rect x="10" y="182" width="170" height="34" rx="8"/>
    <rect x="470" y="14"  width="240" height="50" rx="8"/>
    <rect x="470" y="84"  width="240" height="50" rx="8"/>
    <rect x="470" y="154" width="240" height="50" rx="8" stroke="var(--color-accent)"/>
  </g>
  <g fill="var(--color-fg)" text-anchor="middle">
    <text x="95" y="36">positions/</text>
    <text x="95" y="78">projects/</text>
    <text x="95" y="120">talks/</text>
    <text x="95" y="162">oss/</text>
    <text x="95" y="204">education/</text>
    <text x="590" y="35">/portfolio/</text>
    <text x="590" y="105">/story/TAG/</text>
    <text x="590" y="175" fill="var(--color-accent)">/cv/ + cv.json</text>
  </g>
  <g fill="var(--color-muted)" font-size="11px" text-anchor="middle">
    <text x="590" y="52">the timeline, everything dated</text>
    <text x="590" y="122">cross-linked by shared tags</text>
    <text x="590" y="192">only entries whose cv: opts in</text>
  </g>
  <g stroke="var(--color-muted)" fill="none">
    <line x1="180" y1="115" x2="330" y2="115"/>
  </g>
  <g stroke="var(--color-muted)" fill="var(--color-muted)">
    <line x1="330" y1="115" x2="330" y2="39"/>
    <line x1="330" y1="39" x2="462" y2="39"/><polygon points="462,35 470,39 462,43"/>
    <line x1="330" y1="115" x2="462" y2="109"/><polygon points="462,105 470,109 462,113"/>
    <line x1="330" y1="115" x2="330" y2="179"/>
    <line x1="330" y1="179" x2="462" y2="179"/><polygon points="462,175 470,179 462,183"/>
  </g>
</svg>
</div>

## 1 · The profile

The portfolio's header comes from one file, `portfolio.yaml`, at the site root:

```yaml
name: Juno Vale
headline: Grows orchards and software.
location: Belfast
links:
  - label: GitHub
    url: https://github.com/junovale
  - label: Fediverse
    url: https://fedi.example/@juno
updated: 2026-08-01
```

## 2 · Your first position

Every collection has a schema, and the schema is the contract. Ask before you write:

```text
$ cherry schema portfolio/positions
portfolio/positions frontmatter:
  title: string (required) — Role title, e.g. "Staff Engineer".
  org: string (required) — Organisation name.
  start: date (required) — Start date.
  end: date — End date; omit while the position is current.
  location: string — City / remote — free text.
  tags: list of string [default: []] — Tags from the shared site taxonomy (cross-linked with blog posts).
  highlights: list of string [default: []] — Short bullet points for the timeline entry.
  cv: cv block — CV curation: `{include, weight, highlights}`. Absent → timeline-only.
  ...
```

Then write `content/portfolio/positions/orchard-systems.md`:

```yaml
---
title: Staff Engineer
org: Orchard Systems
start: 2020-02-01
location: Remote
tags:
  - elixir
highlights:
  - Grew the platform from seed to fruit
  - Led a team of five gardeners
cv:
  include: true
  weight: 10
  highlights:
    - Grew the platform from seed to fruit
---
The long-form story of the orchard years, in markdown. This body
renders on the portfolio page; the frontmatter feeds everything else.
```

Omit `end:` while the role is current and the timeline says "present". Note the two highlight lists: the top-level one is for the timeline, the one inside `cv:` is the tighter cut for employers. More on that in step 5.

## 3 · Projects and talks, scaffolded

The generators write valid frontmatter so you do not have to remember it:

```text
$ cherry gen.project "Cider Press" --json
{"ok":true,"command":"gen.project","data":{"path":"content/portfolio/projects/cider-press.md","slug":"cider-press"}}

$ cherry gen.talk "Backpressure in practice" --json
{"ok":true,"command":"gen.talk","data":{"path":"content/portfolio/talks/backpressure-in-practice.md","slug":"backpressure-in-practice"}}
```

Fill in what the scaffold left empty. Projects carry `status:` (`active`, `paused`, `archived`) and `links:`; talks carry `event:`, `date:`, and optionally `video:` and `slides:`. A talk with a recording can embed it right in the body with a [video component](/docs/components/), facade and all:

```text
::video{youtube="q6Yr9DkTn2k" title="Backpressure in practice"}
```

The `oss/` collection (title, repo, role: `author`, `maintainer`, or `contributor`) and `education/` (title, institution, dates) round out the story. The verifier's `unfilled-field` rule nags about any scaffold string you forgot to replace, which is exactly the nag you want before an employer reads the page.

## 4 · The timeline and the story pages

Build, and two surfaces exist already:

- **`/portfolio/`** interleaves everything by date under your profile header: positions as ranges, projects with status, talks and education as points in time.
- **`/story/TAG/`** exists for every tag your portfolio shares with your blog. Tag a position `elixir` and a post `elixir`, and the story page shows the job and the writing side by side. One taxonomy across the whole site, which is the part hand-rolled portfolios always lose.

## 5 · Curate the CV

The timeline is your story for peers; the CV is the cut for employers. The `cv:` block is the whole curation model:

- `include: true` opts an entry in. No block means timeline-only.
- `weight:` orders entries within their section, heaviest first.
- `highlights:` inside `cv:` overrides the timeline bullets with a tighter set.

`/cv/` renders those entries dense and linear: skills backed by years, positions with curated bullets, projects, education. Nothing on it that you did not deliberately include.

## 6 · Print it, and ship the JSON twin

Open `/cv/` and print. The stylesheet strips navigation, forces the light rendition (even from a dark screen, syntax colors included), and lays the page out for A4. That is the one-pager you attach to an application, generated from the same files as everything else.

Beside it, every build emits **`/cv.json`** in [JSON Resume](https://jsonresume.org) format, so the machine-readable version of your CV is never out of date with the human one.

## 7 · Verify like always

```text
$ cherry check --strict
Checked 34 page(s): all clear.
```

The same rules cover the portfolio: broken links in entry bodies, empty scaffold fields, duplicate titles. Push, and the [deploy workflow](/docs/deploy/) puts your story on your domain.

:::tip{title="Keep the CV honest"}
Treat `cv.highlights` as claims you can defend in an interview and the timeline as the evidence behind them. The two-layer design exists so you never pad one to serve the other.
:::
