defmodule Cherry.TeletypeThemeTest do
  use ExUnit.Case, async: true

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.Resolver

  @folio Path.expand("../fixtures/sites/folio", __DIR__)
  @today ~D[2026-08-14]

  test "teletype is an official CSS-only theme and passes conformance" do
    assert "teletype" in Theme.builtin_names()
    assert {:ok, theme} = Theme.load(Theme.builtin_root("teletype"))
    assert theme.name == "teletype"
    assert theme.contract == "1.1"
    assert theme.inherit_templates

    # Same token API as the default theme: site overrides port across.
    {:ok, default} = Theme.load(Theme.default_root())
    assert Keyword.keys(theme.tokens) == Keyword.keys(default.tokens)
  end

  test "teletype ships no templates — every one inherits from the framework" do
    {:ok, theme} = Theme.load(Theme.builtin_root("teletype"))
    site = %Site{title: "t", url: "https://x", base_path: "", root: ".", output: "_s"}

    for spec <- theme.templates do
      assert {:ok, {:framework, _path}} = Resolver.resolve(site, theme, spec.name),
             "#{spec.name} did not resolve to the framework level"
    end
  end

  @tag :tmp_dir
  test "theme: \"teletype\" swaps the world without touching content", %{tmp_dir: tmp} do
    source = Path.join(tmp, "src")
    File.cp_r!(@folio, source)
    File.rm_rf!(Path.join(source, "expected"))

    File.write!(
      Path.join(source, "cherry.exs"),
      ~s([title: "Folio", url: "https://folio.example", theme: "teletype"])
    )

    out = Path.join(tmp, "out")
    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

    css = File.read!(Path.join(out, "assets/site.css"))
    assert css =~ "teletype theme"
    assert css =~ "--color-accent: light-dark(#9a6700, #e3b341)"

    # The Noto Sans Mono subset ships with the site.
    assert File.exists?(Path.join(out, "assets/fonts/noto-sans-mono-latin.woff2"))

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
