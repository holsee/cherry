---
title: The machine surface
description: JSON envelopes, llms.txt, markdown mirrors, and how coding agents operate a Cherry site.
---
## The machine surface

Cherry assumes a coding agent is sitting next to you, and gives it a real interface instead of HTML to scrape. The machine surface has two halves: the CLI an agent drives, and the site it can read back.

### The CLI half

Every verb takes `--json` and emits one envelope shape:

```json
{
  "ok": true,
  "command": "check",
  "data": {
    "errors": 0,
    "warnings": 0,
    "pages": 34,
    "diagnostics": []
  }
}
```

Failures carry a code, a message, and details:

```json
{
  "ok": false,
  "command": "config",
  "error": {
    "code": "usage",
    "message": "invalid flags: --sorce",
    "details": {}
  }
}
```

Exit codes are part of the contract: 0 success, 1 the command ran and failed, 2 usage error. An agent's whole loop is: run a verb, branch on the exit code, parse the envelope, fix what the diagnostics name, repeat. Three verbs make that loop tight:

- **`cherry schema COLLECTION --json`** answers "what does a valid file look like" before anything is written.
- **`cherry check --strict --json`** returns every problem as structured data (`file`, `rule`, `message`, `severity`), each one naming the file that would fix it.
- **`cherry serve --port 0`** binds a free port and reports it in the envelope, so automation never fights over port 4000. The envelope also carries `live_reload`, honestly `false` on mounts where no file watcher works.

### The site half

Every build emits, beside the HTML:

| artefact | what it is |
|---|---|
| `/llms.txt` | the site's table of contents for language models: [this site's own](/llms.txt) |
| `PAGE/index.md` | a markdown mirror beside every page; [this page's](/docs/machine-surface/index.md) |
| `/feed.json` | JSON Feed, alongside Atom |
| `/cv.json` | JSON Resume, when the site has a CV |
| `/search/index.json` | the search index, when `search: "cherry"` |

Your published site is legible without a DOM parser. Curl the markdown mirror and you get the page as the author wrote it, not as the theme rendered it.

### The scaffold teaches the loop

`cherry new` (and the mix archive) write two files that make "point your agent at the repo" a supported path rather than a hack:

- **`AGENTS.md`**: the operating loop in prose: learn the schema first, draft, verify, publish, build, plus the rules (never edit `_site/`, never hand-copy theme files).
- **`.claude/skills/publish/SKILL.md`**: a Claude Code skill that walks a post from `gen.post` through `check --strict` to `publish`.

Cherry's own repository carries the fuller version: a `cherry` skill with a generated command reference that CI keeps honest, so the documentation an agent reads can never drift from the CLI it drives. The [agents guide](/guides/agents/) shows the loop running for real.
