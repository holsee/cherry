# Regenerates the agent skill's command reference from the CLI verb
# registry after any verb, flag, or doc-text change:
#
#     mix run scripts/regen_skill.exs
#
# Review the diff — the skill is part of Cherry's agent API. `mix ci`
# fails while the committed file is stale.
path = Cherry.Skill.reference_path()
File.mkdir_p!(Path.dirname(path))
File.write!(path, Cherry.Skill.commands_reference())
IO.puts("wrote #{path}")
