defmodule Cherry.Commands.GenPortfolioTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @today "2026-08-14"

  @tag :tmp_dir
  test "gen.project scaffolds an entry that builds onto the timeline", %{tmp_dir: tmp} do
    site(tmp)

    {code, output} =
      with_io(fn -> Cherry.CLI.run(["gen.project", "Cider Press", "--source", tmp, "--json"]) end)

    assert code == 0
    assert %{"ok" => true, "data" => data} = JSON.decode!(output)
    assert data["path"] == "content/portfolio/projects/cider-press.md"

    # The scaffold is valid as-is: the site builds and the entry shows.
    out = Path.join(tmp, "_site")
    assert {:ok, _build} = Cherry.build(source: tmp, output: out, today: ~D[2026-08-14])
    assert File.read!(Path.join(out, "portfolio/index.html")) =~ "Cider Press"
  end

  @tag :tmp_dir
  test "gen.talk scaffolds a dated entry that validates", %{tmp_dir: tmp} do
    site(tmp)

    {0, _output} =
      with_io(fn ->
        Cherry.CLI.run(["gen.talk", "Growing on the BEAM", "--source", tmp, "--today", @today])
      end)

    scaffold = File.read!(Path.join(tmp, "content/portfolio/talks/growing-on-the-beam.md"))
    assert scaffold =~ "date: 2026-08-14"

    assert {:ok, _build} = Cherry.build(source: tmp, today: ~D[2026-08-14])
  end

  @tag :tmp_dir
  test "refuses duplicates and empty slugs", %{tmp_dir: tmp} do
    site(tmp)

    {0, _} = with_io(fn -> Cherry.CLI.run(["gen.project", "Widget", "--source", tmp]) end)

    holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(holder, {:code, Cherry.CLI.run(["gen.project", "Widget", "--source", tmp])})
      end)

    assert_receive {:code, 1}
    assert stderr =~ "already exists"

    stderr =
      capture_io(:stderr, fn ->
        send(holder, {:code, Cherry.CLI.run(["gen.talk", "!!!", "--source", tmp])})
      end)

    assert_receive {:code, 2}
    assert stderr =~ "empty slug"
  end

  defp site(tmp) do
    File.write!(Path.join(tmp, "cherry.exs"), ~s|[title: "T", url: "https://t.example"]|)
  end
end
