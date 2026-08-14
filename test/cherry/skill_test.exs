defmodule Cherry.SkillTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The agent-skill drift gate: the committed command reference must match
  what the CLI registry renders today, and the hand-written SKILL.md
  must mention every verb. A new verb cannot land without the skill
  teaching it.
  """

  alias Cherry.CLI.Registry
  alias Cherry.Skill

  @skill "skills/cherry/SKILL.md"
  @pointers [".claude/skills/cherry/SKILL.md", ".agents/skills/cherry/SKILL.md"]

  test "the committed command reference is current" do
    committed = File.read!(Skill.reference_path())

    assert committed == Skill.commands_reference(),
           "#{Skill.reference_path()} is stale — run `mix run scripts/regen_skill.exs` " <>
             "and review the diff"
  end

  test "SKILL.md teaches every registry verb" do
    skill = File.read!(@skill)

    for verb <- Registry.verbs() do
      assert skill =~ verb, "skills/cherry/SKILL.md never mentions the verb #{inspect(verb)}"
    end
  end

  test "SKILL.md links the generated reference" do
    assert File.read!(@skill) =~ "references/commands.md"
  end

  test "tool-specific pointers defer to the canonical skill" do
    for pointer <- @pointers do
      content = File.read!(pointer)

      assert content =~ "skills/cherry/SKILL.md",
             "#{pointer} does not point at the canonical skill"

      assert content =~ "name: cherry"
    end
  end
end
