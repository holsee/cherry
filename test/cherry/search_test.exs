defmodule Cherry.SearchTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Pagefind search (DESIGN.md §"Search"): opt-in via `search: "pagefind"`.
  The layout grows the UI island only when enabled, the Post stage
  indexes the emitted site, and default builds stay byte-identical.
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
