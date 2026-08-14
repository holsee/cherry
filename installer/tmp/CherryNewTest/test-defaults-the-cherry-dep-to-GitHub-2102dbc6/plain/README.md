# Plain

A static site built with [Cherry](https://github.com/holsee/cherry).

| task | purpose |
|---|---|
| `mix cherry.serve` | dev server with live reload |
| `mix cherry.gen.post "Title"` | new draft post |
| `mix cherry.publish PATH` | draft → dated, published post |
| `mix cherry.build` | full build → `_site/` |
| `mix cherry.check` | verifier: links, metadata, feeds |

Agents: start with `AGENTS.md`.
