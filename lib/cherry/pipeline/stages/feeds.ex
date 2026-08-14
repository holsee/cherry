defmodule Cherry.Pipeline.Stages.Feeds do
  @moduledoc """
  Emits the machine-readable surface: `feed.xml` (Atom), `feed.json`
  (JSON Feed), `sitemap.xml`, and `robots.txt` — default-on, zero
  config (DESIGN.md §7).

  Runs after layout so the sitemap can cover every page in the build;
  `404.html` is deliberately excluded from it.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.{Document, Page}
  alias Cherry.SEO.{Feed, JsonFeed}
  alias Cherry.Site

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{site: site} = build) do
    posts =
      build.documents
      |> Enum.filter(&(&1.collection == "posts" and not &1.raw?))
      |> Enum.sort_by(&{Date.to_erl(&1.meta.date), &1.meta.slug}, :desc)

    pages = [
      %Page{source: ":feed", path: "feed.xml", content: Feed.render(site, posts)},
      %Page{source: ":json_feed", path: "feed.json", content: JsonFeed.render(site, posts)},
      %Page{source: ":sitemap", path: "sitemap.xml", content: sitemap(site, build.pages)},
      %Page{source: ":robots", path: "robots.txt", content: robots(site)}
    ]

    {:ok, %Build{build | pages: build.pages ++ pages}}
  end

  defp sitemap(site, pages) do
    urls =
      pages
      |> Enum.reject(& &1.unlisted?)
      |> Enum.map(& &1.path)
      |> Enum.reject(&(&1 == "404.html"))
      |> Enum.sort()
      |> Enum.map(fn path ->
        "<url><loc>#{Site.abs_url(site, Document.rel_url(path))}</loc></url>\n"
      end)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{urls}</urlset>
    """
  end

  defp robots(site) do
    """
    User-agent: *
    Allow: /

    Sitemap: #{Site.abs_url(site, "sitemap.xml")}
    """
  end
end
