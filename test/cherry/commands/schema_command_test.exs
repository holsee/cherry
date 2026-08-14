defmodule Cherry.Commands.SchemaCommandTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  test "cherry schema posts --json prints the introspectable schema" do
    {code, output} = with_io(fn -> Cherry.CLI.run(["schema", "posts", "--json"]) end)

    assert code == 0
    assert %{"ok" => true, "data" => %{"fields" => fields}} = JSON.decode!(output)

    title = Enum.find(fields, &(&1["name"] == "title"))
    assert title["required"] == true
    assert title["type"] == "string"

    tags = Enum.find(fields, &(&1["name"] == "tags"))
    assert tags["type"] == "list of string"
    assert tags["default"] == []
  end

  test "human output lists fields with type and doc" do
    {code, output} = with_io(fn -> Cherry.CLI.run(["schema", "posts"]) end)

    assert code == 0
    assert output =~ "posts frontmatter:"
    assert output =~ "title: string (required)"
    assert output =~ "draft: boolean"
  end

  test "unknown collection exits 2 listing the real ones" do
    code_holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(code_holder, {:code, Cherry.CLI.run(["schema", "nope"])})
      end)

    assert_receive {:code, 2}

    assert stderr =~
             "pages, portfolio/education, portfolio/oss, portfolio/positions, " <>
               "portfolio/projects, portfolio/talks, posts"
  end
end
