defmodule Cherry.Commands.NewCommandTest do
  use ExUnit.Case, async: true

  @moduledoc """
  `cherry new` is the binary lane's scaffold — the one verb a
  binary-only install was missing (the mix lane keeps the `cherry_new`
  archive, which owns the `mix cherry.new` name; core deliberately
  ships no task by that name so the two never collide).
  """

  import ExUnit.CaptureIO

  alias Cherry.CLI

  @moduletag :tmp_dir

  @today "2026-08-14"

  test "scaffolds a site that builds and checks clean", %{tmp_dir: tmp} do
    path = Path.join(tmp, "orchard-lane")

    {code, output} =
      with_io(fn -> CLI.run(["new", path, "--today", @today]) end)

    assert code == 0
    assert output =~ "* creating cherry.exs"
    assert output =~ "* creating AGENTS.md"
    assert output =~ "cherry serve"
    refute output =~ "mix cherry", "the binary-lane scaffold speaks cherry, not mix"

    for file <- [
          "cherry.exs",
          "README.md",
          "AGENTS.md",
          ".claude/skills/publish/SKILL.md",
          "content/pages/index.md",
          "content/pages/about.md",
          "content/posts/#{@today}-hello-cherry.md",
          "static/images/.gitkeep"
        ] do
      assert File.exists?(Path.join(path, file)), "scaffold is missing #{file}"
    end

    # The title humanizes from the directory name.
    assert File.read!(Path.join(path, "cherry.exs")) =~ ~s(title: "Orchard Lane")

    # A fresh scaffold is a working site: builds, and verifies clean.
    assert {:ok, _build} =
             Cherry.build(
               source: path,
               output: Path.join(tmp, "out"),
               today: Date.from_iso8601!(@today)
             )

    assert {:ok, _build, []} = Cherry.check(source: path, today: Date.from_iso8601!(@today))
  end

  test "refuses a non-empty directory", %{tmp_dir: tmp} do
    path = Path.join(tmp, "taken")
    File.mkdir_p!(path)
    File.write!(Path.join(path, "keep.txt"), "mine")

    holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(holder, {:code, CLI.run(["new", path])})
      end)

    assert_receive {:code, 2}
    assert stderr =~ "already exists and is not empty"
    assert File.read!(Path.join(path, "keep.txt")) == "mine"
  end

  test "usage error without a path" do
    holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(holder, {:code, CLI.run(["new"])})
      end)

    assert_receive {:code, 2}
    assert stderr =~ "usage: cherry new PATH"
  end
end
