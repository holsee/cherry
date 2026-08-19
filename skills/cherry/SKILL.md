---
name: cherry
description: Author, build, verify, theme, and deploy Cherry static sites through the `cherry` CLI, and keep the standalone binary current. Use when an agent needs to create or publish posts, projects, or talks, run builds, fix `cherry check` diagnostics, manage themes and overlay drift, generate deploy workflows, or self-update the binary. Do not use for developing Cherry itself unless the task also requires operating a site.
---

# Cherry

Use the `cherry` CLI for deterministic, structured control of a Cherry site. Every verb behaves identically under the standalone binary (`cherry VERB`) and mix (`mix cherry.VERB`) — both are thin wrappers around one seam, so pick whichever the environment provides and never assume they differ.

## Start safely

1. Run `cherry version` (or `mix cherry.version`). If neither works, stop and report that Cherry must be installed — `curl -fsSL https://cherrybomb.dev/install.sh | sh` for the binary.
2. Work from the site root: the directory containing `cherry.exs`. Most commands accept `--source DIR` when running from elsewhere; pass it explicitly in automation rather than relying on the working directory.
3. Add `--json` to every read and every scripted mutation. Success envelopes are `{"ok":true,"command":VERB,"data":{...}}`; failures are `{"ok":false,"command":VERB,"error":{"code":...,"message":...,"details":{...}}}`. Exit codes: 0 success, 1 the command ran and failed, 2 usage error.
4. Discover content shapes with `cherry schema posts --json` (or any collection name) instead of guessing frontmatter fields.

## Follow the operating loop

This is the loop the scaffolded site `AGENTS.md` teaches; keep to it:

1. **Author** — `cherry gen.post "Title"` creates a draft; `cherry gen.project` and `cherry gen.talk` scaffold portfolio entries with valid frontmatter. Capture `data.path` from the envelope and edit that file. Markdown is GFM plus three framework-level content components in remark-directive syntax: `::figure{src="…" alt="…" caption="…"}` (alt is required), `::video{youtube="ID" title="…"}` (renders a zero-request facade; `src=` plays a local file), and `:::note{title="…"} … :::` containers for the five alert types. They are theme-independent by design; misuse is a `component` diagnostic in `cherry check`, never a broken build.
2. **Build** — `cherry build` emits the site to `_site/`. Treat a failing build as the first diagnostic, not an obstacle.
3. **Verify** — `cherry check --strict --json` builds in memory (writes nothing) and reports structured diagnostics. Fix and re-run until clean; do not ship with warnings suppressed.
4. **Preview** — `cherry serve` runs until interrupted (live reload, drafts included). In automation, background it or skip it; never let it block the loop. Prefer `--port 0` there: it binds a free ephemeral port and reports it in the envelope, so a taken port 4000 cannot fail the run. Trust `live_reload` in the envelope over the assumption that edits reload: on a Docker bind mount or a network share it is `false`, and you must rebuild explicitly.
5. **Publish** — `cherry publish SLUG` (the slug `gen.post` returned) or `cherry publish PATH` turns the draft into a dated post.
6. **Deploy** — commit and push; the GitHub Actions workflow from `cherry gen.action` builds and deploys Pages. Regenerate the workflow only when deployment shape changes.

Re-run `cherry check` after any content or theme mutation that later steps depend on; a clean earlier run proves nothing about the current tree.

## Read diagnostics structurally

`cherry check --strict --json` failing exits 1 with `error.code == "check_failed"` and `error.details.diagnostics`, a list of `{file, rule, message, severity}`. Fix by rule, not by message text:

- `broken-link` — an internal href resolves to nothing the build emits.
- `missing-description` / `missing-alt` / `duplicate-title` — SEO and accessibility contract.
- `empty-body` / `unfilled-field` — a scaffold nobody finished: a post with no prose, or frontmatter still holding the empty string a generator wrote. Write the content; do not delete the rule.
- `feed-missing` / `feed-invalid` — Atom or JSON Feed sanity.
- `stale-overlay` / `untracked-overlay` — theme drift; go to the theme section below.

Without `--strict`, warnings stay warnings and only errors fail the check.

## Manage themes by provenance

Never hand-copy a theme file — provenance is what keeps upgrades mergeable.

- Inspect with `cherry theme.list` and `cherry theme.which TEMPLATE` (shows the three-level lookup chain and the winner).
- Restyle before you eject: `cherry theme.tokens` lists the theme's styling API — every CSS token with its default, doc, and any site override — and `cherry config tokens.--color-accent "#7c3aed"` writes an override. Token overrides and the site's `assets/custom.css` load unlayered over the theme's `@layer theme` CSS, so they always win; most restyles never need to touch a template. A token value applies to both light and dark unless written as `light-dark(a, b)`.
- Take ownership of a template with `cherry theme.eject TEMPLATE`; the copy records provenance.
- Templates are EEx or HEEx — the extension decides, and `<name>.html.heex` beats `<name>.html.eex` at the same lookup level. HEEx escapes by default (`raw(@doc.html)` for rendered markdown), supports `:for`/`:if` and `<.component>` calls, and a theme-root `components.exs` (`use Phoenix.Component`) defines components its templates can call. A `.heex` overlay is a rewrite: `theme.diff` reports it `rewritten` (owned, no three-way merge), and `theme.eject` refuses to write a shadowed `.eex` beside it.
- After a Cherry upgrade, run `cherry theme.diff`: `current` needs nothing, `auto_updatable` re-ejects cleanly with `--apply`, `conflict` means both sides moved — merge by hand, then `theme.eject --force`; `untracked` has no provenance — re-eject to adopt it.
- A whole-theme fork is `cherry gen.theme NAME [--from THEME]`.

## Mutate deliberately

- `cherry config` reads and writes `cherry.exs`, so site settings never need an editor: `cherry config` lists everything, `cherry config KEY` reads one, `cherry config KEY VALUE` writes one. The write is validated by reloading the site and rolled back if the value is rejected, and only the changed value is rewritten — comments and layout survive. Structured settings like `nav:` are refused by design; edit those in the file. The exception is theme token overrides, addressed with a dotted key: `cherry config tokens.NAME VALUE` (the name must exist in `cherry theme.tokens`, so typos fail here instead of becoming dead config).
- Activating a scaffolded theme is two commands, not a file edit: `cherry gen.theme NAME` then `cherry config theme themes/NAME`.
- `gen.post`, `gen.project`, `gen.talk`, and `gen.theme` refuse to overwrite existing files; a refusal means the thing exists — read it instead of forcing.
- `publish` moves a file; capture `data.from` and `data.to` and update anything referencing the old path.
- `gen.post` and `publish` accept `--today YYYY-MM-DD` for deterministic dates in tests and reproducible runs.
- The machine surface is part of the output contract: every route also emits an `index.md` mirror and the site serves `/llms.txt`. Do not treat those files as garbage or delete them from `_site/`.

## Keep the binary current

- `cherry upgrade --check` reports the running version against the latest stable GitHub release; it works under mix too and touches nothing.
- `cherry upgrade` downloads this platform's asset, verifies it against the release's `SHA256SUMS`, and swaps the executable in place. It refuses on any checksum problem and leaves the current binary untouched.
- No stable release exists yet? `--check` says so and still exits 0 with `status: "no_stable_release"` — pass `--version vX.Y.Z-rc.N` deliberately to track a prerelease.
- `cherry version --json` carries `revision`, the commit the build was compiled from, so a build from a branch is distinguishable from the release it was branched from. It is `null` for a build compiled from hex.
- Under mix, upgrading the library is `mix deps.update cherry`, not this command.
- On Windows the replaced executable lingers as `.old` (locked while running); it is safe to delete later and the next upgrade reuses it.

## Recover from errors

- Exit 2 (`usage`) — the verb or a flag is wrong; consult the reference below rather than retrying variations.
- `build_failed` — the message names the cause (`no cherry.exs found in ...` means wrong `--source`).
- `check_failed` — work `details.diagnostics` as above.
- `no_site` / `theme_invalid` / `no_overlay` — the site or theme context is missing; verify `--source` and `cherry.exs` before touching theme files.
- `checksum_mismatch` / `checksum_missing` on upgrade — retry once for a torn download; a second failure is a real integrity problem to report, never bypass.
- Do not retry a refused scaffold with force flags unless the user explicitly wants the overwrite.

## Reference

Read [references/commands.md](references/commands.md) for the complete generated per-verb reference — every verb, flag, and doc text, rendered from the CLI registry itself. It is regenerated by `mix run scripts/regen_skill.exs` and CI fails when it is stale, so treat it as current.
