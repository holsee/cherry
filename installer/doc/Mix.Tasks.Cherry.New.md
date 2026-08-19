# `mix cherry.new`
[🔗](https://github.com/holsee/cherry/blob/v0.1.0-rc.3/lib/mix/tasks/cherry.new.ex#L1)

Scaffolds a new Cherry site: content directories, config, a first
post, `AGENTS.md` documenting the agent workflow, and a `.claude`
publish skill.

## Usage

    mix cherry.new PATH [--cherry-path DIR]

The directory name becomes the app name (`my_site` → `:my_site`).
`--cherry-path` points the cherry dependency at a local checkout
instead of GitHub (used by Cherry's own CI to dogfood the generator).

## Next steps

The generator prints them: `mix deps.get`, `mix cherry.serve`,
`mix cherry.gen.action` for the GitHub Pages deploy workflow.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
