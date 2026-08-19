defmodule Cherry.DemoTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The guide gate: `demo/site` is the site `demo/GUIDE.md` builds, so the
  guide is only honest while the site it describes still builds clean.
  Every claim asserted here is one the guide makes in prose.
  """

  @demo Path.expand("../../demo/site", __DIR__)
  @guide Path.expand("../../demo/GUIDE.md", __DIR__)

  # Two full pipeline runs over a 74-page site, competing with the rest of
  # the suite for schedulers.
  @moduletag timeout: 300_000

  @tag :tmp_dir
  test "it builds clean and emits everything the guide shows the reader", %{tmp_dir: tmp} do
    out = Path.join(tmp, "site")

    assert {:ok, _build} = Cherry.build(source: @demo, output: out)
    assert {:ok, _build, diagnostics} = Cherry.check(source: @demo)

    assert diagnostics == [],
           "the guide claims a clean --strict run:\n" <>
             Enum.map_join(diagnostics, "\n", &"  #{&1.severity} #{&1.file}: #{&1.rule}")

    for file <- [
          "index.html",
          "blog/index.html",
          "portfolio/index.html",
          "about/index.html",
          "story/event-sourcing/index.html",
          "backpressure-is-a-product-decision/index.html",
          "search/index.json",
          "search/search.js",
          "favicon.svg",
          "feed.xml",
          "llms.txt",
          "index.md"
        ] do
      assert File.exists?(Path.join(out, file)), "demo build is missing #{file}"
    end

    home = File.read!(Path.join(out, "index.html"))
    assert home =~ ~s(rel="icon"), "the icon convention section claims this is automatic"
    assert home =~ ~s(data-search="/search/index.json"), "the search section claims this is wired"

    # The theming section claims the demo's accent moved to violet through
    # `cherry config tokens.--color-accent` — the ladder's rung 2.
    assert home =~ ~s(<style id="cherry-tokens">)
    assert home =~ "--color-accent: #7c3aed;"

    # The guide's theming section shows the ejected post_list grouping by year.
    blog = File.read!(Path.join(out, "blog/index.html"))
    assert blog =~ "<h2>2025</h2>" and blog =~ "<h2>2026</h2>"
  end

  test "the ejected template keeps the provenance the guide quotes" do
    overlay =
      @demo
      |> Path.join("themes/default/templates/post_list.html.eex")
      |> File.read!()

    assert overlay =~ "cherry:eject theme=default"
  end

  test "the guide only shows verbs the CLI actually has" do
    guide = File.read!(@guide)

    for verb <- Cherry.CLI.Registry.verbs() do
      assert guide =~ "cherry #{verb}", "the guide never shows `cherry #{verb}`"
    end

    # `cherry new` does not exist — scaffolding is the cherry_new archive,
    # and the guide says so. This gate keeps that from regressing into a
    # command a binary-only reader cannot run.
    refute guide =~ ~r/^\$ cherry new /m
  end
end
