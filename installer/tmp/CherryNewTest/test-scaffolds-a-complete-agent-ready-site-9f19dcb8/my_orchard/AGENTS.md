# AGENTS.md — operating My Orchard

This is a Cherry static site. Every task supports `--json` (machine
envelopes) and meaningful exit codes (0 ok, 1 failed, 2 usage).

## The loop

1. **Learn the schema first**: `mix cherry.schema posts --json` says
   exactly what valid frontmatter looks like before you write a file.
2. **Draft**: `mix cherry.gen.post "Title" --json` → returns the path.
   Write the body in GitHub-flavored markdown. Always fill
   `description:` — the checker warns without it.
3. **Verify**: `mix cherry.check --strict --json`. Structured
   diagnostics (`file`, `rule`, `message`, `severity`); fix and
   re-run until clean. Nothing is written to disk by check.
4. **Publish**: `mix cherry.publish path/to/draft.md --json`
   re-dates the file and removes the draft flag.
5. **Build**: `mix cherry.build` → `_site/`. Deterministic: same
   inputs, same bytes.

## Rules

- Never edit `_site/` — it is generated output.
- Frontmatter is schema-validated; `mix cherry.schema COLLECTION`
  lists every field.
- Posts live at `content/posts/YYYY-MM-DD-slug.md`; the filename is
  the date and slug.
- Theme customization is a ladder: config → tokens → `theme.eject`
  (records provenance) → `mix cherry.theme.diff` keeps ejected
  copies upgradeable. Never hand-copy templates.
- The published site carries a machine surface: `/llms.txt`, an
  `index.md` mirror beside every page, `feed.json` — read those
  instead of scraping HTML.

## Deploy

`mix cherry.gen.action` writes the GitHub Pages workflow; pushes to
the default branch then build and deploy automatically.
