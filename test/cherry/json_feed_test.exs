defmodule Cherry.JsonFeedTest do
  use ExUnit.Case, async: true

  @moduledoc """
  `feed.json` per the JSON Feed 1.1 spec: same posts as the Atom feed,
  newest first, absolute URLs, dates from content (ADR 0005), and a
  discovery `<link>` on every page.
  """

  @moduletag :tmp_dir

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @today ~D[2026-08-14]

  test "renders the blog fixture's posts as a valid 1.1 feed", %{tmp_dir: tmp} do
    out = build(tmp)

    feed = out |> Path.join("feed.json") |> File.read!() |> JSON.decode!()

    assert feed["version"] == "https://jsonfeed.org/version/1.1"
    assert feed["title"] == "Orchard"
    assert feed["description"] == "Notes from the orchard."
    assert feed["home_page_url"] == "https://orchard.example/"
    assert feed["feed_url"] == "https://orchard.example/feed.json"
    assert feed["authors"] == [%{"name" => "Orchard"}]

    assert [newest, oldest] = feed["items"]
    assert newest["title"] == "Picking cherries"
    assert oldest["title"] == "Hello, world"
    assert oldest["id"] == "https://orchard.example/hello-world/"
    assert oldest["url"] == "https://orchard.example/hello-world/"
    assert oldest["date_published"] == "2026-01-15T00:00:00Z"
    assert oldest["content_html"] =~ "<strong>filename</strong>"
    assert oldest["tags"] == ["elixir", "meta"]
    assert oldest["summary"] == "The first post in the orchard."
    refute Map.has_key?(newest, "summary")
  end

  test "every page carries the JSON Feed discovery link", %{tmp_dir: tmp} do
    out = build(tmp)

    html = File.read!(Path.join(out, "hello-world/index.html"))

    assert html =~
             ~s(<link rel="alternate" type="application/feed+json" title="Orchard" href="/feed.json">)
  end

  test "feed URLs respect a project-pages base path", %{tmp_dir: tmp} do
    source = Path.join(tmp, "src")
    File.cp_r!(@fixture, source)
    File.rm_rf!(Path.join(source, "expected"))

    File.write!(
      Path.join(source, "cherry.exs"),
      inspect(title: "Orchard", url: "https://orchard.example", base_path: "repo")
    )

    out = Path.join(tmp, "out")
    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)

    feed = out |> Path.join("feed.json") |> File.read!() |> JSON.decode!()
    assert feed["feed_url"] == "https://orchard.example/repo/feed.json"
    assert [%{"url" => "https://orchard.example/repo/picking-cherries/"} | _rest] = feed["items"]
  end

  test "feed.json stays out of the sitemap", %{tmp_dir: tmp} do
    out = build(tmp)

    refute File.read!(Path.join(out, "sitemap.xml")) =~ "feed.json"
  end

  defp build(tmp) do
    source = Path.join(tmp, "src")
    out = Path.join(tmp, "out")
    File.cp_r!(@fixture, source)
    File.rm_rf!(Path.join(source, "expected"))
    {:ok, _build} = Cherry.build(source: source, output: out, today: @today)
    out
  end
end
