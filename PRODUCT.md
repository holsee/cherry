# Product

<!-- impeccable:product-schema v1 -->

Cherry — a static site generator for hackers, a modern take on Octopress, written
in Elixir. Brand: **Cherrybomb** (cherrybomb.dev); package/CLI name `cherry`.

## Platform

Web (static output). The generator runs via mix tasks or a standalone binary; the
designed surfaces are the generated static sites themselves.

## Users

Developers ("hackers") building a personal site: blog + portfolio + CV. They live in
editors and terminals, publish from the command line, and increasingly delegate to
coding agents. Readers of the output are other developers — and agents.

## Product Purpose

Your site is a mix project. Your story is data. Your agent can run the whole thing.
Three pillars: fast static pages, blog, Careers-2.0-style portfolio (timeline + web CV).

## Positioning

The Octopress successor: repo-as-site workflow with 2026 SEO, theming, and agent
support. Differentiates from Hugo/Jekyll/Tableau on portfolio, agents, design quality,
and workflow — design is a feature of this product.

## Capabilities and Constraints

- Output is pure prerendered HTML; **zero JS by default** — enhancements are
  `<script>` islands that fail soft (authored in TypeScript, shipped compiled).
- Light/dark via CSS custom-property tokens only; no hard-coded colors in templates
  (gate-enforced). Manual toggle beats system preference; no-flash inline script.
- Code blocks use MDEx `html_multi_themes` — both highlight palettes emitted,
  switched by CSS, no JS re-highlighting.
- Hand-rolled CSS, no Tailwind, no node in user builds. Deterministic builds.
- Themes obey the versioned theme contract (fixed templates + token manifest).

## Brand Commitments

- **The default theme is its own clean, distinctive world — not Cherrybomb-branded.**
  It ships on other people's sites. (Confirmed 2026-08-14.)
- **The default theme executes the category standard, played straight** (user's
  standing choice, 2026-08-14): a typography-first minimal blog theme at the craft
  level of Bear Blog / Tufte CSS restraint, PaperMod / Starlight dual-theme polish,
  gwern.net reading engineering, and Stripe / Linear spacing discipline. No editor
  cosplay, no smuggled quirk.
- **A separate official `cherrybomb` theme** carries the brand's graffiti/retrowave
  energy and ships as the second theme, proving the swap contract. (Confirmed.)
- Default theme is **truly dual**: light and dark designed with equal weight; the
  toggle is a feature, not an afterthought. (Confirmed.)
- **What a reader must remember: the code blocks** — the best code-reading
  experience on the indie web. (Confirmed.)
- Real name of the maintainer never appears in public docs (LICENSE files excepted).

## Evidence on Hand

Logo art: `assets/cherrybomb_{text,notext,single}.png` (graffiti/retrowave, baked
black background) — reserved for the cherrybomb theme and project site.
Reference content: the old Octopress site (`../site/original`) to be migrated.

## Product Principles

- Typography-first reading; "code and stuff" personality, modernized.
- Agent-first: `--json` everywhere, introspectable schemas, llms.txt + md mirrors.
- Simple beats clever; determinism is a contract.

## Accessibility & Inclusion

Semantic HTML, WCAG AA contrast in both renditions, `prefers-color-scheme`
respected until the user toggles, focus states never removed, motion minimal and
reduced-motion-safe.
