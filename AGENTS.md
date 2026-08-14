# Cherry

A static site generator for hackers — a modern take on Octopress, written in Elixir,
driven by mix tasks, agent-first from day one. **DESIGN.md is the constitution**;
when in doubt, it decides. If implementation must diverge from it, update DESIGN.md
or file an ADR **in the same PR** — the doc is never allowed to go stale.

## Project facts

- **Repo:** `holsee/cherry` on GitHub (origin is set; publish when ready).
- **License:** dual MIT / Apache-2.0 (Rust-style — user's choice of either;
  `LICENSE-MIT` + `LICENSE-APACHE`). Contributions are accepted under both.
  mix.exs package metadata must say `"MIT OR Apache-2.0"`.
- **Domain:** `cherrybomb.dev` — owned by holsee, DNS on Cloudflare. The project's own
  site is dogfood consumer #2: built with Cherry, deployed as a GitHub Page from this
  repo, routed from cherrybomb.dev (CNAME). Consumer #1 is holsee's personal site
  (`../site`). `holsee.dev` is **not** used for anything in this project.

## Map

| Path | What |
|---|---|
| `DESIGN.md` | The constitution: vision, pillars, architecture, theme contract, phases |
| `docs/adr/` | Architecture decision records — one per decided question; read before re-opening any settled debate |
| `DO_NEXT.md` | Ordered backlog of agent-sized vertical slices, each with acceptance criteria |
| `LATER.md` | Parked ideas and later-phase work — park it, don't lose it, don't do it now |
| `CHANGELOG.md` | Keep-a-Changelog format; terse, clear entries linked to their PR; every user-visible change lands under Unreleased in the same PR |
| `AGENTS.md` | This file — the portable, vendor-neutral agent constitution. `CLAUDE.md` is an uncommitted `@AGENTS.md` include (gitignored). Elixir usage rules get appended via `usage_rules` when the mix project lands |
| `test/fixtures/sites/` | Golden fixture sites + committed expected output (created in Phase 1) |
| `example/` | Dogfood site built in CI (created in Phase 1) |
| `LICENSE-MIT`, `LICENSE-APACHE` | Dual license texts |
| `../site/` | The real first consumer: holsee's site; old Octopress content in `../site/original` (source branch) |

## Stack (decided — do not re-litigate; ADRs have the why)

Elixir library + mix tasks. MDEx for markdown, EEx templates, Bandit for `serve`,
YAML frontmatter, Burrito binary later via the `Cherry.CLI.run/1` seam. No Phoenix
dep, no Tailwind, no node in the core pipeline. See `docs/adr/`.

## The gates (Definition of Done)

**`mix precommit` is the single source of truth for quality gates.** CI runs exactly
that alias and nothing else — never a hand-copied list of steps in the workflow file.
(Lesson inherited from tikichi F-0003: five stale copies of the gate list is how a
green run lies.)

The alias grows with the project; target contents:

1. `compile --warnings-as-errors`
2. `format --check-formatted`
3. `credo --strict`
4. `test` (includes golden-fixture tests)
5. Determinism gate: build a fixture site twice → the two `_site/` trees must be
   byte-identical (this is a test, not a script)

CI matrix: **ubuntu + windows** from the first workflow. Cherry is developed on
Windows; path bugs are first-party bugs.

## Testing strategy (SSG-specific)

- **Golden fixture sites**: `test/fixtures/sites/<name>/` in → committed expected
  output compared file-by-file. Failures print a real diff. Regeneration is an
  explicit task (`mix cherry.goldens --update`) so golden churn is visible in PR
  diffs, never silent.
- **Stages are pure**: every pipeline stage is token-in → token-out, unit-testable
  without touching disk beyond the load stage. Architecture serves testability on
  purpose.
- **Base-path matrix**: every URL-emitting feature is tested at root *and* under
  `/repo/` (the GH Pages project-page case).
- **Theme contract conformance**: `cherry.check` runs against every official theme
  in CI; the contract is executable, not aspirational.

## Working practices

- **Vertical slices**: every DO_NEXT item is one agent-session-sized slice that
  ships something visible (task + test + doc), never a horizontal layer.
- **Gitflow**: `main` holds releases; work merges to `develop` via short-lived
  `feature/*` branches (plus `release/*` / `hotfix/*` when the time comes). PRs small
  enough to review in one sitting. Conventional commits (`feat:`, `fix:`, `docs:`, …).
- **ADR discipline**: new irreversible decision, or deviation from DESIGN.md →
  short ADR (Context / Decision / Consequences) in `docs/adr/`, numbered, filed in
  the same PR as the change.
- **Docs are single-sourced**: a mix task's `@shortdoc`/`@moduledoc` *is* its CLI
  help *is* its hexdocs entry. Never describe a task's flags in two places.
- **Dogfood or it didn't happen**: features aren't done until `example/` (and
  eventually `../site/`) uses them and builds green in CI.
- **`--json` from birth**: any new task ships its `--json` mode with the task, not
  retrofitted. Agents are users, not an afterthought.

## Code style

- **Simple and clear beats clever.** Prefer the obvious implementation; reach for
  abstraction only when the third caller shows up.
- **Comments are for what the code can't say**: constraints, invariants, "why not the
  obvious way." Never narrate what the next line does; just enough to ensure clarity,
  no more.
- **TypeScript for every JS surface** — no untyped `.js`. The theme's script islands
  (toggle, livereload client) and any tooling are authored in TS *in this repo* and
  ship as compiled JS assets, so user site builds stay node-free (the no-node core
  rule is about *their* pipeline, not our dev-time toolchain).

## House rules

- Determinism is a contract: same inputs → byte-identical `_site/`. Anything that
  injects wall-clock time, random IDs, or map-ordering into output is a bug.
- Theme templates use tokens only; a hard-coded color in a template is a review
  finding.
- Windows is not a porting target, it's a development platform. `Path.join/2`
  always; no shelling out to POSIX-only tools in the core.
- Public API (config keys, frontmatter schema fields, theme contract) changes get a
  CHANGELOG entry and, once past 0.x early days, a deprecation path.
