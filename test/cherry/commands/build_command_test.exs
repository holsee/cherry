defmodule Cherry.Commands.BuildCommandTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @fixture Path.expand("../../fixtures/sites/minimal", __DIR__)

  @tag :tmp_dir
  test "cherry build --json reports counts and output dir", %{tmp_dir: tmp} do
    out = Path.join(tmp, "site")

    {code, output} =
      with_io(fn ->
        Cherry.CLI.run(["build", "--source", @fixture, "--out", out, "--json"])
      end)

    assert code == 0

    assert %{"ok" => true, "command" => "build", "data" => data} = JSON.decode!(output)
    assert data == %{"output" => out, "pages" => 7, "assets" => 3}
    assert File.exists?(Path.join(out, "index.html"))
  end

  @tag :tmp_dir
  test "human output states pages, assets, and destination", %{tmp_dir: tmp} do
    out = Path.join(tmp, "site")

    {code, output} =
      with_io(fn -> Cherry.CLI.run(["build", "--source", @fixture, "--out", out]) end)

    assert code == 0
    assert output =~ "Built 7 page(s), 3 asset(s)"
    assert output =~ out
  end

  @tag :tmp_dir
  test "a broken site exits 1 with the loader's message", %{tmp_dir: tmp} do
    code_holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(code_holder, {:code, Cherry.CLI.run(["build", "--source", tmp])})
      end)

    assert_receive {:code, 1}
    assert stderr =~ "no cherry.exs found"
  end
end
