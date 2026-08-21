defmodule Cherry.MachineTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The machine surface (DESIGN.md §6): every content route carries an
  `index.md` mirror alongside its `index.html`, and `/llms.txt` indexes
  the site per the llmstxt.org convention — absolute links, unlisted
  pages excluded, never listed in sitemap or feed.
  """

  @moduletag :tmp_dir

  @blog Path.expand("../fixtures/sites/blog", __DIR__)
  @folio Path.expand("../fixtures/sites/folio", __DIR__)
  @today ~D[2026-08-14]

  describe "markdown mirrors on the blog fixture" do
    test "every markdown route gets its index.md twin", %{tmp_dir: tmp} do
      out = build(tmp, @blog)

      post = File.read!(Path.join(out, "hello-world/index.md"))
      assert post =~ "# Hello, world"
      assert post =~ "*2026-01-15*"
      assert post =~ "The date and slug come from the **filename**"
      refute post =~ "<p>"

      about = File.read!(Path.join(out, "about/index.md"))
      assert about =~ "# About"

      root = File.read!(Path.join(out, "index.md"))
      assert String.starts_with?(root, "# ")
    end

    test "the blog index and tag pages mirror as link lists", %{tmp_dir: tmp} do
      out = build(tmp, @blog)

      index = File.read!(Path.join(out, "blog/index.md"))
      assert index =~ "# Blog"
      assert index =~ "- [Hello, world](/hello-world/index.md) — 2026-01-15"
      assert index =~ "- [Picking cherries](/picking-cherries/index.md) — 2026-02-01"

      tag = File.read!(Path.join(out, "blog/tags/meta/index.md"))
      assert tag =~ "# Tagged: meta"
      assert tag =~ "(/hello-world/index.md)"
      refute tag =~ "Picking cherries"
    end

    test "mirrors stay out of the sitemap and feed", %{tmp_dir: tmp} do
      out = build(tmp, @blog)

      sitemap = File.read!(Path.join(out, "sitemap.xml"))
      refute sitemap =~ "index.md"
      refute sitemap =~ "llms.txt"
      refute File.read!(Path.join(out, "feed.xml")) =~ "index.md"
    end
  end

  describe "llms.txt on the blog fixture" do
    test "indexes posts and pages with absolute mirror links", %{tmp_dir: tmp} do
      out = build(tmp, @blog)

      llms = File.read!(Path.join(out, "llms.txt"))
      assert llms =~ "# Orchard"
      assert llms =~ "## Blog"
      assert llms =~ "- [Blog](https://orchard.example/blog/index.md)"
      assert llms =~ "- [Hello, world](https://orchard.example/hello-world/index.md) — 2026-01-15"
      assert llms =~ "## Pages"
      assert llms =~ "(https://orchard.example/about/index.md)"
      refute llms =~ "## Portfolio"
      refute llms =~ "## CV"
    end

    test "every link respects a project-pages base path", %{tmp_dir: tmp} do
      source = copy(tmp, @blog)

      File.write!(
        Path.join(source, "cherry.exs"),
        inspect(title: "Orchard", url: "https://orchard.example", base_path: "repo")
      )

      out = Path.join(tmp, "out")
      {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

      llms = File.read!(Path.join(out, "llms.txt"))

      for [url] <- Regex.scan(~r/\((https:[^)]+)\)/, llms, capture: :all_but_first) do
        assert String.starts_with?(url, "https://orchard.example/repo/"),
               "llms.txt link outside the base path: #{url}"
      end

      assert File.read!(Path.join(out, "blog/index.md")) =~ "(/repo/hello-world/index.md)"
    end
  end

  describe "the portfolio and CV mirrors (folio fixture)" do
    test "timeline, story, and CV routes carry markdown twins", %{tmp_dir: tmp} do
      out = build(tmp, @folio)

      timeline = File.read!(Path.join(out, "cv/timeline/index.md"))
      assert timeline =~ "# Portfolio"
      assert timeline =~ "grower — Grows orchards and software."
      assert timeline =~ "## 2020"
      assert timeline =~ "**Staff Engineer** · Orchard Systems — Feb 2020 — present"
      assert timeline =~ "## Open source"
      assert timeline =~ "[Trellis]("

      story = File.read!(Path.join(out, "story/elixir/index.md"))
      assert story =~ "# The elixir story"
      assert story =~ "## Positions"
      assert story =~ "## Posts"
      assert story =~ "(/pruning-processes/index.md)"

      cv = File.read!(Path.join(out, "cv/index.md"))
      assert cv =~ "# grower"
      assert cv =~ "*Updated August 2026*"
      assert cv =~ "## Skills"
      assert cv =~ "- elixir — 7 yrs"
      assert cv =~ "## Experience"
      assert cv =~ "**Staff Engineer** · Orchard Systems"
      refute cv =~ "Hedgerow"
    end

    test "llms.txt announces portfolio, stories, and a public CV", %{tmp_dir: tmp} do
      out = build(tmp, @folio)

      llms = File.read!(Path.join(out, "llms.txt"))
      assert llms =~ "- [Portfolio](https://folio.example/cv/timeline/index.md)"
      assert llms =~ "- [The elixir story](https://folio.example/story/elixir/index.md)"
      assert llms =~ "- [CV](https://folio.example/cv/index.md)"
      assert llms =~ "- [JSON Resume](https://folio.example/cv.json)"
    end

    test "an unlisted CV keeps its mirror but leaves llms.txt", %{tmp_dir: tmp} do
      source = copy(tmp, @folio)
      profile = File.read!(Path.join(source, "portfolio.yaml"))
      File.write!(Path.join(source, "portfolio.yaml"), profile <> "cv:\n  visibility: unlisted\n")

      out = Path.join(tmp, "out")
      {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

      assert File.exists?(Path.join(out, "cv/index.md"))
      llms = File.read!(Path.join(out, "llms.txt"))
      refute llms =~ "## CV"
      assert llms =~ "## Portfolio"
    end
  end

  defp build(tmp, fixture) do
    source = copy(tmp, fixture)
    out = Path.join(tmp, "out")
    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)
    out
  end

  defp copy(tmp, fixture) do
    source = Path.join(tmp, "src")
    File.cp_r!(fixture, source)
    File.rm_rf!(Path.join(source, "expected"))
    source
  end
end
