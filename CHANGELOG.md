# Changelog

All notable changes to Cherry are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning follows SemVer once 0.1.0 ships.

Entries are terse one-liners linked to their PR: `- Thing that changed. (#12)`

## [Unreleased]

### Added
- Portfolio data layer: typed collections (`portfolio/positions`, `projects`, `talks`, `oss`, `education`) with introspectable schemas, `portfolio.yaml` profile, `cv:` curation blocks, and domain structs (`Position`, `Project`, `Talk`, `OpenSource`, `Education`, `Profile`, `CV`, `Link`) materialised via `Cherry.Portfolio.from_build/1`; entries are data-only (no page routes). (#11)
- cherrybomb.dev deploy: Pages workflow building `example/` on push to main with CNAME; reserved `/install.sh` and `/install.ps1` installer paths (ADR 0007). (#10)
- `cherry gen.action`: generates the GitHub Pages deploy workflow (build → upload → deploy, `.nojekyll`, CNAME for custom domains); `example/` dogfood site (the future cherrybomb.dev) now builds in every CI run. (#9)
- Default-on SEO and machine surface: canonical/Open Graph/JSON-LD head block on every page, Atom `feed.xml`, `sitemap.xml`, `robots.txt`; `base_path` support so every emitted URL works under GitHub project pages, proven by a base-path matrix test. (#8)
- Authoring loop: `cherry gen.post`, `cherry publish`, and `cherry serve` (Bandit + watcher + SSE live reload, drafts included). (#7)
- Default theme design: dual light/dark token palettes, class-linked syntax highlighting colored by theme tokens, no-flash theme toggle island (TS), token-discipline tests. (#6)
- Theme contract v1: `theme.exs` manifest, three-level lookup, `theme.list`/`theme.which`/`theme.eject` with provenance; default theme renders posts, blog index, tag pages, 404. (#5)
- Typed collections: posts + pages with introspectable schemas (`mix cherry.schema`), YAML frontmatter, MDEx GFM rendering, drafts/future filtering. (#4)
- Build pipeline (load→validate→transform→layout→emit), `cherry.exs` site config, `mix cherry.build`, golden-fixture harness, determinism gate. (#3)
- `Cherry.CLI.run/1` seam with verb registry, `--json` envelopes, stable exit codes; `mix cherry.version` tracer. (#2)
- Library skeleton with `mix precommit` gate, TS toolchain, and CI on ubuntu + windows. (#1)
- Project constitution (AGENTS.md), design doc (DESIGN.md), ADRs 0001–0006, backlog.
- Dual MIT / Apache-2.0 license.
- End-state README with the Cherrybomb identity.
- Devcontainer reference environment (Elixir 1.20.2 / OTP 28 / Node 22, pinned).
- Minimal 0.0.1 package stub to claim `cherry` on Hex (published).
- Portfolio dual-view design: Careers-style timeline + `/cv/` web CV, both
  projections of one dataset (DESIGN.md §4).
