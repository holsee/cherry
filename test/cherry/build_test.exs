defmodule Cherry.BuildTest do
  use ExUnit.Case, async: true

  import Cherry.GoldenAssertions

  alias Cherry.Build.Options
  alias Cherry.Pipeline.Stages

  @fixture Path.expand("../fixtures/sites/minimal", __DIR__)
  @golden Path.join(@fixture, "expected")

  describe "Cherry.build/1" do
    @tag :tmp_dir
    test "renders the minimal fixture to match its golden tree", %{tmp_dir: tmp} do
      out = Path.join(tmp, "site")

      assert {:ok, build} = Cherry.build(source: @fixture, output: out)

      # 2 raw pages + the synthetic blog index and 404 + feed/sitemap/robots
      # + blog index.md mirror + llms.txt (raw pages get no mirrors)
      # + feed.json.
      assert length(build.pages) == 10
      # site.css + theme-toggle.js + copy-code.js + static file.
      assert length(build.assets) == 4

      assert_trees_equal(@golden, out)
    end

    @tag :tmp_dir
    test "is deterministic: two builds are byte-identical (ADR 0005)", %{tmp_dir: tmp} do
      out1 = Path.join(tmp, "one")
      out2 = Path.join(tmp, "two")

      assert {:ok, _} = Cherry.build(source: @fixture, output: out1)
      assert {:ok, _} = Cherry.build(source: @fixture, output: out2)

      assert_trees_equal(out1, out2)
    end

    test "fails with a message naming the config file when it is missing" do
      assert {:error, message} = Cherry.build(source: System.tmp_dir!())
      assert message =~ "no cherry.exs found"
    end
  end

  describe "Cherry.Site.load/2" do
    @tag :tmp_dir
    test "invalid config names the file and the field", %{tmp_dir: tmp} do
      File.write!(Path.join(tmp, "cherry.exs"), "[url: \"https://example.com\"]")

      assert {:error, message} = Cherry.Site.load(tmp)
      assert message =~ "cherry.exs"
      assert message =~ ":title"
    end
  end

  describe "pipeline stages" do
    test "are pure: the same token in gives the same token out" do
      {:ok, site} = Cherry.Site.load(@fixture)
      token = Cherry.Build.new(site, Options.new())

      {:ok, once} = Stages.Load.run(token)
      {:ok, twice} = Stages.Load.run(token)
      assert once == twice

      for stage <- [Stages.Validate, Stages.Transform, Stages.Layout] do
        assert {:ok, from_once} = stage.run(once)
        assert {:ok, from_twice} = stage.run(twice)
        assert from_once == from_twice
      end
    end

    test "load produces sorted, forward-slashed relative paths" do
      {:ok, site} = Cherry.Site.load(@fixture)
      {:ok, build} = Stages.Load.run(Cherry.Build.new(site, Options.new()))

      sources = Enum.map(build.documents, & &1.source)
      assert sources == Enum.sort(sources)

      for path <- sources ++ Enum.map(build.assets, & &1.path) do
        refute path =~ "\\"
      end
    end
  end
end
