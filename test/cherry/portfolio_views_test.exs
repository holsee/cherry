defmodule Cherry.PortfolioViewsTest do
  use ExUnit.Case, async: true

  import Cherry.GoldenAssertions

  alias Cherry.Portfolio
  alias Cherry.Portfolio.Timeline

  @fixture Path.expand("../fixtures/sites/folio", __DIR__)
  @golden Path.join(@fixture, "expected")
  @today ~D[2026-08-14]

  describe "the folio fixture" do
    @tag :tmp_dir
    test "builds to match its golden tree", %{tmp_dir: tmp} do
      out = Path.join(tmp, "site")

      assert {:ok, build} = Cherry.build(source: @fixture, output: out, today: @today)

      # 1 page + 1 post + blog index + 1 tag page + timeline + 2 stories
      # + 404 + feed/sitemap/robots.
      assert length(build.pages) == 11
      assert_trees_equal(@golden, out)
    end

    @tag :tmp_dir
    test "the timeline page tells the story", %{tmp_dir: tmp} do
      out = build!(tmp)
      timeline = File.read!(Path.join(out, "portfolio/index.html"))

      # Profile header, Person JSON-LD, and the nav knows the page exists.
      assert timeline =~ "<h1>grower</h1>"
      assert timeline =~ "Grows orchards and software."
      assert timeline =~ ~s("@type":"Person")
      assert timeline =~ ~s("worksFor":{"@type":"Organization","name":"Orchard Systems"})
      assert timeline =~ ~s(<a href="/portfolio/">Portfolio</a>)

      # Entries with kind labels, ranges, and story-linked tags.
      assert timeline =~ "Staff Engineer · Orchard Systems"
      assert timeline =~ "Feb 2020 — present"
      assert timeline =~ "Software Engineer · Hedgerow Ltd"
      assert timeline =~ "Growing on the BEAM"
      assert timeline =~ "BSc Pomology · Orchard University"
      assert timeline =~ ~s(<a href="/story/elixir/">elixir</a>)

      # OSS is a standing role, not a dated event.
      assert timeline =~ "Trellis"
      assert timeline =~ ~s(<span class="oss-role">author</span>)
    end

    @tag :tmp_dir
    test "story pages cross-link portfolio and posts on one tag", %{tmp_dir: tmp} do
      out = build!(tmp)
      story = File.read!(Path.join(out, "story/elixir/index.html"))

      assert story =~ "The elixir story"
      assert story =~ "Staff Engineer · Orchard Systems"
      assert story =~ "Cider Press"
      assert story =~ "Growing on the BEAM"
      assert story =~ "Trellis"
      assert story =~ ~s(<a href="/pruning-processes/">Pruning processes</a>)
      # The erlang position is not part of the elixir story.
      refute story =~ "Hedgerow"

      # The blog tag page points at the story.
      tag_page = File.read!(Path.join(out, "blog/tags/elixir/index.html"))
      assert tag_page =~ ~s(<a href="/story/elixir/">)
    end

    @tag :tmp_dir
    test "sites without a portfolio gain nothing", %{tmp_dir: tmp} do
      blog = Path.expand("../fixtures/sites/blog", __DIR__)
      out = Path.join(tmp, "site")

      assert {:ok, _build} = Cherry.build(source: blog, output: out, today: @today)
      refute File.exists?(Path.join(out, "portfolio"))
      refute File.exists?(Path.join(out, "story"))
      refute File.read!(Path.join(out, "index.html")) =~ "Portfolio"
    end
  end

  describe "Timeline.groups/1" do
    @tag :tmp_dir
    test "groups by year, newest first, mixed kinds", %{tmp_dir: tmp} do
      out = Path.join(tmp, "site")
      {:ok, build} = Cherry.build(source: @fixture, output: out, today: @today)

      groups = build |> Portfolio.from_build() |> Timeline.groups()

      assert Enum.map(groups, &elem(&1, 0)) == [2024, 2023, 2020, 2016, 2012]

      {2024, [talk]} = List.keyfind(groups, 2024, 0)
      assert talk.kind == :talk

      {2012, [education]} = List.keyfind(groups, 2012, 0)
      assert education.kind == :education
    end
  end

  defp build!(tmp) do
    out = Path.join(tmp, "site")
    {:ok, _build} = Cherry.build(source: @fixture, output: out, today: @today)
    out
  end
end
