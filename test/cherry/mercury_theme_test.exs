defmodule Cherry.MercuryThemeTest do
  use ExUnit.Case, async: true

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.Resolver

  @folio Path.expand("../fixtures/sites/folio", __DIR__)
  @today ~D[2026-08-14]

  test "mercury is an official theme (contract 1.1) and passes conformance" do
    assert "mercury" in Theme.builtin_names()
    assert {:ok, theme} = Theme.load(Theme.builtin_root("mercury"))
    assert theme.name == "mercury"
    assert theme.contract == "1.1"
    assert theme.inherit_templates

    # Same token API as the default theme: site overrides port across.
    {:ok, default} = Theme.load(Theme.default_root())
    assert Keyword.keys(theme.tokens) == Keyword.keys(default.tokens)
  end

  test "mercury ships layout, page — the rest inherit from the framework" do
    {:ok, theme} = Theme.load(Theme.builtin_root("mercury"))
    site = %Site{title: "t", url: "https://x", base_path: "", root: ".", output: "_s"}
    shipped = [:layout, :page]

    for spec <- theme.templates do
      expected = if spec.name in shipped, do: :theme, else: :framework

      assert {:ok, {^expected, _path}} = Resolver.resolve(site, theme, spec.name),
             "#{spec.name} did not resolve to the #{expected} level"
    end
  end

  @tag :tmp_dir
  test "theme: \"mercury\" swaps the world without touching content", %{tmp_dir: tmp} do
    source = Path.join(tmp, "src")
    File.cp_r!(@folio, source)
    File.rm_rf!(Path.join(source, "expected"))

    File.write!(
      Path.join(source, "cherry.exs"),
      ~s([title: "Folio", url: "https://folio.example", theme: "mercury"])
    )

    out = Path.join(tmp, "out")
    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

    css = File.read!(Path.join(out, "assets/site.css"))
    assert css =~ "mercury theme"
    assert css =~ "--color-accent: light-dark(#4d3bd6, #a99bff)"

    assert File.exists?(Path.join(out, "assets/fonts/dela-gothic-latin.woff2"))
    assert File.exists?(Path.join(out, "assets/fonts/lexend-latin.woff2"))
    assert File.exists?(Path.join(out, "assets/mercury-pool.js"))
    index = File.read!(Path.join(out, "index.html"))
    assert index =~ "class=\"mercury-band\""
    assert index =~ "class=\"hero hero-chrome\""

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
