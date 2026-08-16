defmodule Cherry.SearchTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Search (DESIGN.md §"Search"), opt-in either way: `search: "cherry"`
  indexes in-process and emits its own island, `search: "pagefind"`
  shells out after emit. The layout grows a search box only when one is
  configured, and default builds stay byte-identical.
  """

  @moduletag :tmp_dir

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  test "the config rejects unknown search engines", %{tmp_dir: tmp} do
    source = fixture(tmp, ~s(search: "algolia"))

    assert {:error, message} = Cherry.Site.load(source)
    assert message =~ "search"
  end

  test "enabled: every page grows the UI island, and check stays clean", %{tmp_dir: tmp} do
    source = fixture(tmp, ~s(search: "pagefind"))

    {:ok, build, diagnostics} = Cherry.check(source: source, today: @today)

    page = Enum.find(build.pages, &(&1.path == "hello-world/index.html"))
    assert page.content =~ ~s(<link rel="stylesheet" href="/pagefind/pagefind-ui.css">)
    assert page.content =~ ~s(<div id="search" class="site-search">)
    assert page.content =~ "new PagefindUI"

    # The pagefind assets land post-Emit; the link checker knows that.
    assert Enum.filter(diagnostics, &(&1.severity == :error)) == []
  end

  test "disabled: not a byte of pagefind anywhere", %{tmp_dir: tmp} do
    source = fixture(tmp, nil)

    {:ok, build, _diagnostics} = Cherry.check(source: source, today: @today)

    refute Enum.any?(build.pages, &(&1.content =~ "pagefind"))
  end

  test "a full build runs Pagefind and emits the index", %{tmp_dir: tmp} do
    source = fixture(tmp, ~s(search: "pagefind"))
    out = Path.join(tmp, "out")

    assert {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

    assert File.exists?(Path.join(out, "pagefind/pagefind-ui.js"))
    assert File.exists?(Path.join(out, "pagefind/pagefind-ui.css"))
    assert File.exists?(Path.join(out, "pagefind/pagefind.js"))
  end

  describe ~s(the built-in engine, search: "cherry") do
    test "grows a search box wired to the emitted index", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s(search: "cherry"))

      {:ok, build, diagnostics} = Cherry.check(source: source, today: @today)

      page = Enum.find(build.pages, &(&1.path == "hello-world/index.html"))
      assert page.content =~ ~s(<div class="site-search" data-search="/search/index.json">)
      assert page.content =~ ~s(<input type="search" class="site-search-input")
      assert page.content =~ ~s(<script src="/search/search.js" defer></script>)

      assert Enum.filter(diagnostics, &(&1.severity == :error)) == []
    end

    test "emits the index and the island, and nothing from Pagefind", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s(search: "cherry"))

      {:ok, build, _diagnostics} = Cherry.check(source: source, today: @today)

      assert Enum.find(build.pages, &(&1.path == "search/index.json"))
      assert Enum.find(build.pages, &(&1.path == "search/search.js"))
      refute Enum.any?(build.pages, &(&1.content =~ "pagefind"))
    end

    test "keeps the index out of the sitemap and the machine surface", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s(search: "cherry"))

      {:ok, build, _diagnostics} = Cherry.check(source: source, today: @today)

      sitemap = Enum.find(build.pages, &(&1.path == "sitemap.xml"))
      llms = Enum.find(build.pages, &(&1.path == "llms.txt"))

      refute sitemap.content =~ "search/index.json"
      refute llms.content =~ "search/index.json"
    end

    test "a full build writes an index that decodes and finds a post", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s(search: "cherry"))
      out = Path.join(tmp, "out")

      assert {:ok, _build} = Cherry.build(source: source, output: out, today: @today)
      assert File.exists?(Path.join(out, "search/search.js"))

      index = out |> Path.join("search/index.json") |> File.read!() |> JSON.decode!()
      id = Enum.find_index(index["docs"], &(&1["u"] == "/hello-world/"))

      assert Enum.any?(index["terms"]["hello"], fn [doc_id, _weight] -> doc_id == id end)
    end

    test "builds byte-identically twice — the index is in the deterministic tree", %{tmp_dir: tmp} do
      source = fixture(tmp, ~s(search: "cherry"))

      index = fn out ->
        assert {:ok, _build} = Cherry.build(source: source, output: out, today: @today)
        out |> Path.join("search/index.json") |> File.read!()
      end

      assert index.(Path.join(tmp, "one")) == index.(Path.join(tmp, "two"))
    end
  end

  defp fixture(tmp, search_line) do
    source = Path.join(tmp, "src")
    File.cp_r!(@fixture, source)
    File.rm_rf!(Path.join(source, "expected"))

    config =
      ~s([title: "Orchard", url: "https://orchard.example") <>
        if(search_line, do: ", #{search_line}]", else: "]")

    File.write!(Path.join(source, "cherry.exs"), config)
    source
  end
end
