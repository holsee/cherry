# AGENTS.md — operating this site

This is a Cherry static site. Every verb supports `--json` (machine
envelopes) and meaningful exit codes (0 ok, 1 failed, 2 usage).

Commands below are the standalone binary. This demo is built from the
Cherry checkout that contains it, so in this repository each one is
`mix cherry.<verb> --source demo/site` instead.

## The loop

1. **Learn the schema first**: `cherry schema posts --json` says exactly
   what valid frontmatter looks like before you write a file.
2. **Draft**: `cherry gen.post "Title" --json` → returns the path and
   slug. Write the body in GitHub-flavored markdown. Always fill
   `description:` — the checker warns without it.
3. **Verify**: `cherry check --strict --json`. Structured diagnostics
   (`file`, `rule`, `message`, `severity`); fix and re-run until clean.
   Nothing is written to disk by check.
4. **Publish**: `cherry publish SLUG --json` removes the draft flag and
   dates the post today; pass `--today YYYY-MM-DD` to date it otherwise.
5. **Build**: `cherry build` → `_site/`. Deterministic: same inputs,
   same bytes.

## Rules

- Never edit `_site/` — it is generated output.
- Frontmatter is schema-validated; `cherry schema COLLECTION` lists
  every field.
- Posts live at `content/posts/YYYY-MM-DD-slug.md`; the filename carries
  the date and the slug.
- Site settings are a command, not an edit: `cherry config KEY VALUE`
  writes `cherry.exs`, validates by reloading the site, and rolls back a
  value the schema rejects.
- Theme customization is a ladder: config → tokens → `cherry theme.eject`
  (records provenance) → `cherry theme.diff` keeps ejected copies
  upgradeable. Never hand-copy templates.
- The published site carries a machine surface: `/llms.txt`, an
  `index.md` mirror beside every page, `feed.json` — read those instead
  of scraping HTML.
- `cherry serve` reports `live_reload` in its envelope. On a Docker bind
  mount or a network share it is `false`: rebuild explicitly rather than
  waiting for a reload that cannot arrive.

## Deploy

`cherry gen.action` writes the GitHub Pages workflow; pushes to the
configured branch then build and deploy automatically. Set the publishing
source to GitHub Actions once, in the repository's Pages settings.
