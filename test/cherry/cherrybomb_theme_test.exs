defmodule Cherry.CherrybombThemeTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias Cherry.Theme

  @folio Path.expand("../fixtures/sites/folio", __DIR__)
  @today ~D[2026-08-14]

  test "cherrybomb is an official theme and passes conformance" do
    assert "cherrybomb" in Theme.builtin_names()
    assert {:ok, theme} = Theme.load(Theme.builtin_root("cherrybomb"))
    assert theme.name == "cherrybomb"
    assert theme.contract == "1.0"

    # Same token API as the default theme: site overrides port across.
    {:ok, default} = Theme.load(Theme.default_root())
    assert Keyword.keys(theme.tokens) == Keyword.keys(default.tokens)
  end

  @tag :tmp_dir
  test "theme: \"cherrybomb\" swaps the world without touching content", %{tmp_dir: tmp} do
    out = build_with_theme(tmp, ~s("cherrybomb"))

    css = File.read!(Path.join(out, "assets/site.css"))
    assert css =~ "CherryBomb"
    assert css =~ "--color-accent: light-dark(#c0134f, #ff4d7d)"

    # Same pages, same routes — only the world changed.
    for file <- [
          "pruning-processes/index.html",
          "portfolio/index.html",
          "cv/index.html",
          "404.html"
        ] do
      assert File.exists?(Path.join(out, file)), "missing #{file}"
    end
  end

  @tag :tmp_dir
  test "gen.theme scaffolds an editable copy that builds", %{tmp_dir: tmp} do
    source = site_copy(tmp)

    {code, output} =
      with_io(fn ->
        Cherry.CLI.run(["gen.theme", "neon", "--from", "cherrybomb", "--source", source])
      end)

    assert code == 0
    assert output =~ ~s(theme: "themes/neon")

    manifest = File.read!(Path.join(source, "themes/neon/theme.exs"))
    assert manifest =~ ~s(name: "neon")

    out = rebuild_with_theme(source, tmp, ~s("themes/neon"))
    assert File.exists?(Path.join(out, "assets/site.css"))

    # Refuses to clobber.
    holder = self()

    stderr =
      capture_io(:stderr, fn ->
        send(holder, {:code, Cherry.CLI.run(["gen.theme", "neon", "--source", source])})
      end)

    assert_receive {:code, 1}
    assert stderr =~ "already exists"
  end

  defp build_with_theme(tmp, theme_value) do
    source = site_copy(tmp)
    rebuild_with_theme(source, tmp, theme_value)
  end

  defp rebuild_with_theme(source, tmp, theme_value) do
    out = Path.join(tmp, "out-#{System.unique_integer([:positive])}")

    File.write!(
      Path.join(source, "cherry.exs"),
      ~s([title: "Folio", url: "https://folio.example", theme: #{theme_value}])
    )

    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)
    out
  end

  defp site_copy(tmp) do
    source = Path.join(tmp, "src")

    unless File.dir?(source) do
      File.cp_r!(@folio, source)
      File.rm_rf!(Path.join(source, "expected"))
    end

    source
  end
end
