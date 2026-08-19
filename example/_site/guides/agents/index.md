# Scripting and agents

# Scripting and agents

Every Cherry command has a machine-readable side: stable exit codes, JSON envelopes, introspectable schemas. That makes the CLI pleasant to drive from a shell script with `jq`. Paired with the shipped skill, it's just as workable for a coding agent helping run your site.

## The envelope contract

Add `--json` to any verb. Success is always:

```json
{
  "ok": true,
  "command": "build",
  "data": {
    "output": "_site",
    "pages": 12,
    "assets": 2
  }
}
```

Failure is always:

```json
{
  "ok": false,
  "command": "check",
  "error": {
    "code": "check_failed",
    "message": "…",
    "details": {
      "diagnostics": ["…"]
    }
  }
}
```

Exit codes are stable: `0` success, `1` the command ran and failed, `2` usage error. `error.code` is a machine identifier, and `error.details` is structured data: a failing check hands back its full diagnostics list, not prose to parse. A registry-completeness test in Cherry's own suite makes it impossible to add a verb without envelope coverage.

## Never guess frontmatter

Collections carry introspectable schemas:

```sh
cherry schema posts --json
```

```json
{
  "ok": true,
  "command": "schema",
  "data": {
    "collection": "posts",
    "fields": [
      {
        "name": "title",
        "type": "string",
        "required": true,
        "doc": "Post title."
      },
      {
        "name": "date",
        "type": "date",
        "doc": "ISO 8601 date; defaults to the date in the filename."
      },
      {
        "name": "slug",
        "type": "string",
        "doc": "URL slug; defaults to the filename after the date."
      },
      {
        "name": "tags",
        "type": "list of string",
        "default": [],
        "doc": "Tags from the shared site taxonomy."
      },
      {
        "name": "draft",
        "type": "boolean",
        "default": false,
        "doc": "Drafts are skipped unless `--drafts`."
      },
      {
        "name": "description",
        "type": "string",
        "doc": "Meta description for SEO and feeds."
      }
    ]
  }
}
```

Unknown frontmatter keys are hard build errors. The schema is the contract, so ask it first.

## The built site's readable twin

The output is as scriptable as the input. Every Cherry site ships:

- **[/llms.txt](/llms.txt)**: an index of the site with links to plain-markdown versions of every listed page (the llmstxt.org convention).
- **A markdown mirror beside every route**: this page is also [/guides/agents/index.md](/guides/agents/index.md), clean markdown with no theme wrapping. `curl` any page's `index.md` and you get what the author wrote.
- **`feed.json`** (JSON Feed 1.1) alongside Atom, and JSON-LD structured data in every post's head.

## The skill

If a coding agent helps run your site, don't make it rediscover the CLI: Cherry ships [a skill](https://github.com/holsee/cherry/tree/develop/skills/cherry) with the operating loop, the error-recovery playbook, and a command reference that's generated from the CLI registry and drift-gated in CI, so it can't lie about the verb surface. Sites scaffolded with `cherry.new` also carry an `AGENTS.md` describing the same loop in-repo:

1. `cherry schema <collection> --json` to learn the shape.
2. `cherry gen.post "Title" --json` and capture `data.path`.
3. Write the file.
4. `cherry check --strict --json` and work `error.details.diagnostics` until `ok: true`.
5. `cherry publish <path> --json` and capture the new path from `data.to`.
6. Commit and push; the deploy workflow does the rest.

The same six steps are a perfectly good `Makefile`; that's the point. Nothing here is agent-only. It's one interface that scripts, CI, and agents all share.
