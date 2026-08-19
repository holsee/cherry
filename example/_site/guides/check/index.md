# The verifier

# The verifier

`cherry check` builds the whole site in memory, writes nothing, and runs every rule against the result. It's the difference between "the build passed" and "the site is right."

## A worked failure

Add a link to a page that doesn't exist, then check:

```sh
cherry check --strict --json
```

```json
{
  "ok": false,
  "command": "check",
  "error": {
    "code": "check_failed",
    "message": "Checked 12 page(s): 1 error(s), 0 warning(s).",
    "details": {
      "errors": 1,
      "warnings": 0,
      "pages": 12,
      "diagnostics": [
        {
          "file": "content/pages/reading.md",
          "rule": "broken-link",
          "severity": "error",
          "message": "links to /guides/pruning/, which this build does not emit",
          "line": null
        }
      ]
    }
  }
}
```

Everything needed to fix it is in the diagnostic: the **file**, the **rule**, and a message naming the exact href. Exit code 1 tells CI; `details.diagnostics` tells whatever script is watching. Fix the link, run again:

```json
{
  "ok": true,
  "command": "check",
  "data": {
    "errors": 0,
    "warnings": 0,
    "diagnostics": [],
    "pages": 12
  }
}
```

## The rules

| Rule | Catches | Severity |
|---|---|---|
| `broken-link` | internal hrefs the build doesn't emit, nav links included | error |
| `missing-description` | posts and pages without a `description:` (SEO contract) | warning |
| `missing-alt` | images without alt text | warning |
| `duplicate-title` | two pages claiming the same title | warning |
| `feed-missing` / `feed-invalid` | Atom or JSON Feed absent or malformed | error |
| `stale-overlay` / `untracked-overlay` | theme drift (see [themes](/guides/themes/)) | warning |

`--strict` promotes warnings to errors; use it in CI so nothing rots quietly. This site runs `check --strict` on every commit.

> [!TIP]
> `check` accepts `--drafts` and `--future` too, so you can verify work-in-progress exactly as `serve` shows it.

## Where it fits

Run it after every meaningful edit, not just before deploys. It's fast, it writes nothing, and the loop is the point: **build, check, fix, repeat** until exit 0, then ship. The [scripting guide](/guides/agents/) shows the same loop driven entirely through envelopes.
