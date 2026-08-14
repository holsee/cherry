# Changelog

All notable changes to Cherry are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning follows SemVer once 0.1.0 ships.

Entries are terse one-liners linked to their PR: `- Thing that changed. (#12)`

## [Unreleased]

### Added
- Standalone binary + release pipeline (ADR 0007): Burrito packaging (`Cherry.Binary` boots the CLI seam only in `CHERRY_RELEASE` builds), tag-gated release workflow with a five-target native-runner matrix, per-binary smoke tests, `SHA256SUMS` + build-provenance attestation, prerelease-aware publishing, and real checksum-verifying `install.sh` / `install.ps1` served from cherrybomb.dev; `workflow_dispatch` runs the whole matrix as a publish-nothing dry run. (#24)
- Published build action (`holsee/cherry/action`): composite GitHub Action doing toolchain setup, caching, `cherry.build`, and `cherry.check` (strict by default) in one `uses:` step — GH Pages users never touch Elixir locally; `gen.action` workflows now wrap it, and CI exercises the action against a fresh `cherry.new` site on both OSes. (#23)
- Optional Pagefind search: `search: "pagefind"` in `cherry.exs` — the new Post pipeline stage indexes the emitted site (`npx pagefind`), both official themes grow a token-styled search island only when enabled, and default builds stay byte-identical and dependency-free. (#22)
- `mix cherry.new PATH` (the `cherry_new` installer, `installer/`): scaffolds an agent-ready site — content dirs, config (including the Lumis NIF selection consumers must carry), first post, `AGENTS.md` documenting the operate loop, and a `.claude/skills/publish` skill; CI dogfoods a generated site with `build` + `check --strict` against every commit. (#21)
- `cherry theme.diff`: managed drift — every overlay's three-way status against the installed theme (`current` / `auto_updatable` / `conflict` / `untracked`), `--apply` re-ejects auto-updatable ones with fresh provenance, and `cherry check` warns on stale or untracked overlays. Frozen theme copies, answered. (#20)
- JSON Feed: `feed.json` (jsonfeed.org 1.1) alongside Atom with a discovery `<link>` on every page; `cherry check` now verifies it too. (#19)
- The machine surface: every content route now carries an `index.md` markdown mirror alongside its `index.html` (posts, pages, blog index, tag pages, portfolio timeline, stories, CV), plus a generated `/llms.txt` per the llmstxt.org convention with absolute links to the mirrors; unlisted pages keep their mirrors but stay out of `llms.txt`, and mirrors never leak into the sitemap or feed. (#18)
- `--json` contract audit: error envelopes now carry structured `details` (a failing `check --strict --json` returns its diagnostics machine-readably, not just prose), and a registry-complete contract test proves every verb's success and error envelopes decode — new verbs cannot land without envelope coverage. (#17)
- `cherry check`: the verifier — builds in memory (writes nothing) and reports structured diagnostics (broken internal links, missing descriptions, images without alt text, duplicate titles, Atom feed sanity); errors exit 1, `--strict` promotes warnings, `--json` feeds the agent's build → check → fix loop. (#16)
- The cherrybomb theme: second official theme carrying the brand — neon night wall by dark, poster paper by day, brush-stroke title, glowing code blocks — same contract and token API as the default, proving the swap is real; `cherry gen.theme NAME [--from THEME]` scaffolds an editable site-local copy. (#15)
- `cherry gen.project` and `cherry gen.talk`: portfolio scaffolds with valid frontmatter (build-clean as generated), duplicate refusal, `--json` for agents. (#14)
- The CV view: `/cv/` as an employer-shaped projection of the portfolio (cv: curation, weight ordering, curated bullets), evidence-backed skills derived from merged calendar spans and linked to story pages, `/cv.json` in JSON Resume format, print-first stylesheet (black-on-white, no chrome, no split entries), and `visibility: public | unlisted | off` with noindex/sitemap handling. (#13)
- Portfolio views: `/portfolio/` timeline (profile header, year-railed entries, open source as standing roles), `/story/:tag/` pages cross-linking positions/projects/talks/OSS/education with blog posts on one tag, `Person` JSON-LD, nav that knows the portfolio exists, and blog tag pages linking to their story. (#12)
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

### Fixed
- Date ordering everywhere dates entered sort keys: `%Date{}` structs term-compare field-alphabetically (day before year), so feeds, the blog index, tag pages, the timeline, and skills could order Jan 15 above Feb 1; all sort keys now go through `Date.to_erl/1`. (#19)
- Byte-determinism of emitted JSON: atom-keyed map iteration follows atom-creation order and varies between VM runs, so `JSON.encode!` output was not reproducible; `feed.json` and `cv.json` now encode via `Cherry.StableJSON` with sorted object keys (ADR 0005). (#19)
