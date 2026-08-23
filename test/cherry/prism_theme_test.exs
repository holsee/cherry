defmodule Cherry.PrismThemeTest do
  use ExUnit.Case, async: true

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.Resolver

  @folio Path.expand("../fixtures/sites/folio", __DIR__)
  @today ~D[2026-08-14]

  test "prism is an official theme (contract 1.1, one shipped template) and passes conformance" do
    assert "prism" in Theme.builtin_names()
    assert {:ok, theme} = Theme.load(Theme.builtin_root("prism"))
    assert theme.name == "prism"
    assert theme.contract == "1.1"
    assert theme.inherit_templates

    # Same token API as the default theme: site overrides port across.
    {:ok, default} = Theme.load(Theme.default_root())
    assert Keyword.keys(theme.tokens) == Keyword.keys(default.tokens)
  end

  test "prism ships only its layout — the rest inherit from the framework" do
    {:ok, theme} = Theme.load(Theme.builtin_root("prism"))
    site = %Site{title: "t", url: "https://x", base_path: "", root: ".", output: "_s"}

    for spec <- theme.templates do
      expected = if spec.name == :layout, do: :theme, else: :framework

      assert {:ok, {^expected, _path}} = Resolver.resolve(site, theme, spec.name),
             "#{spec.name} did not resolve to the #{expected} level"
    end
  end

  @tag :tmp_dir
  test "theme: \"prism\" swaps the world without touching content", %{tmp_dir: tmp} do
    source = Path.join(tmp, "src")
    File.cp_r!(@folio, source)
    File.rm_rf!(Path.join(source, "expected"))

    File.write!(
      Path.join(source, "cherry.exs"),
      ~s([title: "Folio", url: "https://folio.example", theme: "prism"])
    )

    out = Path.join(tmp, "out")
    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

    css = File.read!(Path.join(out, "assets/site.css"))
    assert css =~ "prism theme"
    assert css =~ "--color-accent: light-dark(#6d28d9, #a78bfa)"

    # The Instrument Sans subset, the mesh island, and its canvas ship.
    assert File.exists?(Path.join(out, "assets/fonts/instrument-sans-latin.woff2"))
    assert File.exists?(Path.join(out, "assets/prism-mesh.js"))
    index = File.read!(Path.join(out, "index.html"))
    assert index =~ ~s(class="prism-mesh")
    assert index =~ "prism-mesh.js"

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
