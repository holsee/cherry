# DO NEXT — ordered vertical slices (Phase 1)

Each slice is one agent-session-sized unit: code + tests + docs + CHANGELOG, gated by
`mix precommit`. Do them in order; each ships something visible.

## 1. Project bootstrap
`mix new cherry` (library), `precommit` alias (compile w-a-e, format, credo --strict,
test), CI workflow running exactly `mix precommit` on ubuntu + windows, `usage_rules`
appended to AGENTS.md, hexdocs config. Gitflow branches: `develop` created, CI on PRs
to `develop` and `main`. TS toolchain (tsconfig + esbuild) for the future islands.
**AC:** CI green on both OSes; `mix precommit` is the only gate command anywhere;
first PR merges `feature/bootstrap` → `develop` with a conventional-commit history.

## 2. CLI seam + first task
`Cherry.CLI.run/1` dispatcher (ADR 0006): verb registry, `--json` envelope, exit
codes. `mix cherry.version` as the tracer-bullet task through the seam.
**AC:** `mix cherry.version` and `mix cherry.version --json` both work; task help
single-sourced from the module.

## 3. Build pipeline skeleton + golden harness
Stage behaviour (token-in/token-out), load → validate → transform → layout → emit as
no-op-to-minimal stages. Golden fixture harness: `test/fixtures/sites/minimal/` →
committed expected `_site/`; determinism test (build twice, byte-identical, ADR 0005).
**AC:** `mix cherry.build` renders the minimal fixture; golden + determinism tests in
suite; failure output is a readable diff.

## 4. Collections + posts
Collection schemas (NimbleOptions-style; ADR 0003), YAML frontmatter parsing, `pages`
+ `posts` built-ins, tags, drafts/future filtering, `/:title/` permalinks, MDEx
rendering with GFM.
**AC:** fixture site with 3 posts + tags builds; invalid frontmatter fails naming
file + field; `mix cherry.schema posts --json` prints the schema.

## 5. Theme contract v1 + default theme structure
`theme.exs` manifest (contract version, template inventory, token manifest; ADR 0004),
three-level lookup, `theme.list` / `theme.which`, `theme.eject` with provenance
header. Unstyled-but-correct default templates.
**AC:** contract conformance check passes for default theme; ejecting a template and
editing it survives a rebuild; `theme.which post` prints the resolution chain.

## 6. Default theme design pass
Tokens (:root light palette, dark via prefers-color-scheme + data-theme override),
no-flash toggle, MDEx html_multi_themes code blocks, typography-first layout.
**Use the impeccable skill for this slice.**
**AC:** fixture site renders beautifully in both themes; zero JS except the toggle
island; no hard-coded colors in templates (grep-gated in precommit).

## 7. gen.post / publish / serve
`mix cherry.gen.post "Title"` (draft with valid frontmatter, `--json` returns path),
`mix cherry.publish`, `mix cherry.serve` (Bandit + watcher + livereload).
**AC:** full Octopress loop works: gen → write → serve (live reload on edit) →
publish → build.

## 8. SEO + feeds
Canonical URLs, OG/Twitter meta, JSON-LD BlogPosting, Atom feed, sitemap.xml,
robots.txt, 404. Base-path (`base_url`) correctness with root + `/repo/` matrix tests.
**AC:** feeds validate; every emitted URL respects base_url in both matrix cases.

## 9. GH Pages + dogfood
`mix cherry.gen.action` (setup-beam → build → upload-pages-artifact → deploy-pages,
`.nojekyll`, CNAME). `example/` dogfood site building in CI. Migrate holsee.github.io
posts from `../site/original` (source branch) into `../site` as a Cherry site.
**AC:** `../site` builds with Cherry and is deployable to GH Pages; old permalinks
preserved (`/:title/`).

## 10. Project site at cherrybomb.dev
Minimal-but-designed Cherry-built project site (landing + docs pointers) living in
this repo, deployed via the generated GH Pages workflow, CNAME `cherrybomb.dev`,
apex/www routing configured. Reserve `/install.sh` (+ `/install.ps1`) paths — the
site later serves the binary installer (ADR 0007).
**AC:** https://cherrybomb.dev serves the Cherry-built site over the custom-domain
path; it doubles as `example/` or replaces it as the in-repo dogfood.

---
Phase 2 (portfolio, second theme, gen.theme) and Phase 3 (check suite, llms.txt +
md mirrors, theme.diff, binary, Pagefind, build-action, cherry_new archive) are
sequenced in DESIGN.md §10; pull them in here when Phase 1 closes.
