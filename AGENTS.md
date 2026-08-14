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

`mix ci` is an alias for `mix precommit` — run it locally for confidence and rapid
feedback *before* pushing; GitHub CI should only ever confirm what you already saw.
The alias grows with the project; current contents:

1. `compile --warnings-as-errors`
2. `format --check-formatted`
3. `credo --strict` — config in `.credo.exs`; `Readability.Specs` is enforced
   (every public function carries a `@spec`). When a house standard needs
   mechanical enforcement, write a custom check in `checks/` and require it
   from `.credo.exs` rather than relying on review.
4. `dialyzer` (dialyxir) — proves the specs; PLTs cached in `priv/plts`
   (gitignored, cached in CI keyed on mix.lock)
5. TS check (`npm run check` → `tsc --noEmit`, run via the OS shell — OTP can't
   spawn `npm.cmd` directly on Windows)
6. `test` (includes golden-fixture tests)
7. Determinism gate: build a fixture site twice → the two `_site/` trees must be
   byte-identical (this is a test, not a script)

CI matrix: **ubuntu + windows** from the first workflow. Cherry is developed on
Windows; path bugs are first-party bugs.

## Testing strategy (SSG-specific)

- **Golden fixture sites**: `test/fixtures/sites/<name>/` in → committed expected
  output compared file-by-file. Failures print a real diff. Regeneration is an
  explicit task (`mix cherry.goldens --update`) so golden churn is visible in PR
  diffs, never silent.
- **Agent skill drift gate**: `skills/cherry/SKILL.md` (canonical; `.claude/` and
  `.agents/` carry pointers) teaches agents the CLI. Its command reference is
  generated from the verb registry — after any verb/flag/doc change run
  `mix run scripts/regen_skill.exs`; the test suite fails while it is stale, and
  also fails when SKILL.md doesn't mention a registry verb.
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
- **Gitflow**: `main` holds tagged releases; work merges to `develop` via short-lived
  `feature/*` branches (plus `release/*` / `hotfix/*` when the time comes). `develop`
  is the GitHub default branch, so PRs target it automatically — never open a PR
  against `main` except a release merge-down. PRs small enough to review in one
  sitting. Conventional commits (`feat:`, `fix:`, `docs:`, …).
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
- **Well-typed Elixir.** Domain data rides in named structs (`%Site{}`, `%Post{}`,
  `%Theme{}`), never loose maps; every struct has `@type t`; every public function
  has a `@spec` (credo enforces, dialyzer proves). Modules are organised by domain
  with a small number of high-level entry modules; developer aesthetics matter —
  the module tree should read like the architecture.
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

<!-- usage-rules-start -->
<!-- usage-rules-header -->
# Usage Rules

**IMPORTANT**: Consult these usage rules early and often when working with the packages listed below.
Before attempting to use any of these packages or to discover if you should use them, review their
usage rules to understand the correct patterns, conventions, and best practices.
<!-- usage-rules-header-end -->

<!-- usage_rules-start -->
## usage_rules usage
_A dev tool for Elixir projects to gather LLM usage rules from dependencies_

## Using Usage Rules

Many packages have usage rules, which you should *thoroughly* consult before taking any
action. These usage rules contain guidelines and rules *directly from the package authors*.
They are your best source of knowledge for making decisions.

## Modules & functions in the current app and dependencies

When looking for docs for modules & functions that are dependencies of the current project,
or for Elixir itself, use `mix usage_rules.docs`

```
# Search a whole module
mix usage_rules.docs Enum

# Search a specific function
mix usage_rules.docs Enum.zip

# Search a specific function & arity
mix usage_rules.docs Enum.zip/1
```


## Searching Documentation

You should also consult the documentation of any tools you are using, early and often. The best 
way to accomplish this is to use the `usage_rules.search_docs` mix task. Once you have
found what you are looking for, use the links in the search results to get more detail. For example:

```
# Search docs for all packages in the current application, including Elixir
mix usage_rules.search_docs Enum.zip

# Search docs for specific packages
mix usage_rules.search_docs Req.get -p req

# Search docs for multi-word queries
mix usage_rules.search_docs "making requests" -p req

# Search only in titles (useful for finding specific functions/modules)
mix usage_rules.search_docs "Enum.zip" --query-by title
```


<!-- usage_rules-end -->
<!-- usage_rules:elixir-start -->
## usage_rules:elixir usage
# Elixir Core Usage Rules

## Pattern Matching
- Use pattern matching over conditional logic when possible
- Prefer to match on function heads instead of using `if`/`else` or `case` in function bodies
- `%{}` matches ANY map, not just empty maps. Use `map_size(map) == 0` guard to check for truly empty maps

## Error Handling
- Use `{:ok, result}` and `{:error, reason}` tuples for operations that can fail
- Avoid raising exceptions for control flow
- Use `with` for chaining operations that return `{:ok, _}` or `{:error, _}`

## Common Mistakes to Avoid
- Elixir has no `return` statement, nor early returns. The last expression in a block is always returned.
- Don't use `Enum` functions on large collections when `Stream` is more appropriate
- Avoid nested `case` statements - refactor to a single `case`, `with` or separate functions
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Lists and enumerables cannot be indexed with brackets. Use pattern matching or `Enum` functions
- Prefer `Enum` functions like `Enum.reduce` over recursion
- When recursion is necessary, prefer to use pattern matching in function heads for base case detection
- Using the process dictionary is typically a sign of unidiomatic code
- Only use macros if explicitly requested
- There are many useful standard library functions, prefer to use them where possible

## Function Design
- Use guard clauses: `when is_binary(name) and byte_size(name) > 0`
- Prefer multiple function clauses over complex conditional logic
- Name functions descriptively: `calculate_total_price/2` not `calc/2`
- Predicate function names should not start with `is` and should end in a question mark.
- Names like `is_thing` should be reserved for guards

## Data Structures
- Use structs over maps when the shape is known: `defstruct [:name, :age]`
- Prefer keyword lists for options: `[timeout: 5000, retries: 3]`
- Use maps for dynamic key-value data
- Prefer to prepend to lists `[new | list]` not `list ++ [new]`

## Mix Tasks

- Use `mix help` to list available mix tasks
- Use `mix help task_name` to get docs for an individual task
- Read the docs and options fully before using tasks

## Testing
- Run tests in a specific file with `mix test test/my_test.exs` and a specific test with the line number `mix test path/to/test.exs:123`
- Limit the number of failed tests with `mix test --max-failures n`
- Use `@tag` to tag specific tests, and `mix test --only tag` to run only those tests
- Use `assert_raise` for testing expected exceptions: `assert_raise ArgumentError, fn -> invalid_function() end`
- Use `mix help test` to for full documentation on running tests

## Debugging

- Use `dbg/1` to print values while debugging. This will display the formatted value and other relevant information in the console.

<!-- usage_rules:elixir-end -->
<!-- usage_rules:otp-start -->
## usage_rules:otp usage
# OTP Usage Rules

## GenServer Best Practices
- Keep state simple and serializable
- Handle all expected messages explicitly
- Use `handle_continue/2` for post-init work
- Implement proper cleanup in `terminate/2` when necessary

## Process Communication
- Use `GenServer.call/3` for synchronous requests expecting replies
- Use `GenServer.cast/2` for fire-and-forget messages.
- When in doubt, use `call` over `cast`, to ensure back-pressure
- Set appropriate timeouts for `call/3` operations

## Fault Tolerance
- Set up processes such that they can handle crashing and being restarted by supervisors
- Use `:max_restarts` and `:max_seconds` to prevent restart loops

## Task and Async
- Use `Task.Supervisor` for better fault tolerance
- Handle task failures with `Task.yield/2` or `Task.shutdown/2`
- Set appropriate task timeouts
- Use `Task.async_stream/3` for concurrent enumeration with back-pressure

<!-- usage_rules:otp-end -->
<!-- usage-rules-end -->
