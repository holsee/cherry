# Cherry Build action

Builds (and verifies) a [Cherry](https://github.com/holsee/cherry) site in
CI — contributors edit markdown in the web UI, the action does the rest.
No local Elixir toolchain required.

```yaml
- uses: actions/checkout@v7

# Pin to a cherry release tag; @develop also works if you want the edge.
- uses: holsee/cherry/action@v0.1.0-rc.2
  with:
    source: .        # the site's mix project (default ".")
    check: strict    # strict | warn | off (default "strict")

- uses: actions/upload-pages-artifact@v5
  with:
    path: _site
```

| input | default | meaning |
|---|---|---|
| `source` | `.` | directory of the site's mix project |
| `check` | `strict` | `cherry.check` mode after the build; `warn` fails only on errors, `off` skips |
| `otp-version` | `28.x` | passed to `erlef/setup-beam` |
| `elixir-version` | `1.20.x` | passed to `erlef/setup-beam` |

Output `output-path` is the built `_site` directory. Dependency and build
caches are keyed on the site's `mix.lock`.

`mix cherry.gen.action` generates a complete GitHub Pages workflow around
this action, pinned to the release tag of the cherry that generated it.
