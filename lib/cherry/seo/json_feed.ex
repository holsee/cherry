defmodule Cherry.SEO.JsonFeed do
  @moduledoc """
  The JSON Feed (`feed.json`), per the [jsonfeed.org](https://jsonfeed.org)
  1.1 spec — the Atom feed's twin for JSON-native readers and agents
  (DESIGN.md §6).

  Same post selection, same dates-from-content determinism (ADR 0005).
  """

  alias Cherry.Content.Document
  alias Cherry.Site

  @version "https://jsonfeed.org/version/1.1"

  @doc "Renders the JSON Feed for the given posts (newest first)."
  @spec render(Site.t(), [Document.t()]) :: String.t()
  def render(%Site{} = site, posts) do
    %{
      version: @version,
      title: site.title,
      home_page_url: Site.abs_url(site, ""),
      feed_url: Site.abs_url(site, "feed.json"),
      authors: [%{name: site.author}],
      items: Enum.map(posts, &item(site, &1))
    }
    |> maybe(:description, site.description)
    |> Cherry.StableJSON.encode!()
  end

  defp item(site, post) do
    url = Site.abs_url(site, Document.rel_url(post.path))

    %{
      id: url,
      url: url,
      title: post.meta.title,
      content_html: post.html,
      date_published: Date.to_iso8601(post.meta.date) <> "T00:00:00Z",
      tags: post.meta.tags
    }
    |> maybe(:summary, post.meta[:description])
  end

  defp maybe(map, _key, nil), do: map
  defp maybe(map, key, value), do: Map.put(map, key, value)
end
