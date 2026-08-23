defmodule Cherry.SwissThemeTest do
  use ExUnit.Case, async: true

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.Resolver

  @folio Path.expand("../fixtures/sites/folio", __DIR__)
  @today ~D[2026-08-14]

  test "swiss is an official theme (contract 1.1) and passes conformance" do
    assert "swiss" in Theme.builtin_names()
    assert {:ok, theme} = Theme.load(Theme.builtin_root("swiss"))
    assert theme.name == "swiss"
    assert theme.contract == "1.1"
    assert theme.inherit_templates

    # Same token API as the default theme: site overrides port across.
    {:ok, default} = Theme.load(Theme.default_root())
    assert Keyword.keys(theme.tokens) == Keyword.keys(default.tokens)
  end

  test "swiss ships layout, page, post_list — the rest inherit from the framework" do
    {:ok, theme} = Theme.load(Theme.builtin_root("swiss"))
    site = %Site{title: "t", url: "https://x", base_path: "", root: ".", output: "_s"}
    shipped = [:layout, :page, :post_list]

    for spec <- theme.templates do
      expected = if spec.name in shipped, do: :theme, else: :framework

      assert {:ok, {^expected, _path}} = Resolver.resolve(site, theme, spec.name),
             "#{spec.name} did not resolve to the #{expected} level"
    end
  end

  @tag :tmp_dir
  test "theme: \"swiss\" swaps the world without touching content", %{tmp_dir: tmp} do
    source = Path.join(tmp, "src")
    File.cp_r!(@folio, source)
    File.rm_rf!(Path.join(source, "expected"))

    File.write!(
      Path.join(source, "cherry.exs"),
      ~s([title: "Folio", url: "https://folio.example", theme: "swiss"])
    )

    out = Path.join(tmp, "out")
    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

    css = File.read!(Path.join(out, "assets/site.css"))
    assert css =~ "swiss theme"
    assert css =~ "--color-accent: light-dark(#e2001a, #ff2d3f)"

    assert File.exists?(Path.join(out, "assets/fonts/familjen-latin.woff2"))
    index = File.read!(Path.join(out, "index.html"))
    assert index =~ "class=\"swiss-grid\""
    assert index =~ "class=\"swiss-home\""

    # Same pages, same routes — only the world changed.
    for file <- [
          "pruning-processes/index.html",
          "portfolio/index.html",
          "cv/timeline/index.html",
          "cv/index.html",
          "404.html"
        ] do
      assert File.exists?(Path.join(out, file)), "missing #{file}"
    end
  end
end
