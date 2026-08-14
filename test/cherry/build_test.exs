defmodule Cherry.BuildTest do
  use ExUnit.Case, async: true

  import Cherry.GoldenAssertions

  alias Cherry.Pipeline.Stages

  @fixture Path.expand("../fixtures/sites/minimal", __DIR__)
  @golden Path.join(@fixture, "expected")

  describe "Cherry.build/1" do
    @tag :tmp_dir
    test "renders the minimal fixture to match its golden tree", %{tmp_dir: tmp} do
      out = Path.join(tmp, "site")

      assert {:ok, build} = Cherry.build(source: @fixture, output: out)
      assert length(build.pages) == 2
      assert length(build.assets) == 1

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
    test "are pure token-in/token-out between load and emit" do
      {:ok, site} = Cherry.Site.load(@fixture)
      {:ok, loaded} = Stages.Load.run(Cherry.Build.new(site))

      for stage <- [Stages.Validate, Stages.Transform, Stages.Layout] do
        assert {:ok, ^loaded} = stage.run(loaded)
      end
    end

    test "load produces sorted, forward-slashed relative paths" do
      {:ok, site} = Cherry.Site.load(@fixture)
      {:ok, build} = Stages.Load.run(Cherry.Build.new(site))

      paths = Enum.map(build.pages, & &1.path)
      assert paths == Enum.sort(paths)

      for path <- paths ++ Enum.map(build.assets, & &1.path) do
        refute path =~ "\\"
      end
    end
  end
end
