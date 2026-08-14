defmodule Cherry.SEO.Feed do
  @moduledoc """
  The Atom feed (`feed.xml`).

  `updated` comes from the newest post, never the clock — the feed is part
  of the byte-identical output contract (ADR 0005).
  """

  alias Cherry.Content.Document
  alias Cherry.Site

  @doc "Renders the Atom feed for the given posts (newest first)."
  @spec render(Site.t(), [Document.t()]) :: String.t()
  def render(%Site{} = site, posts) do
    updated = feed_updated(posts)

    entries = Enum.map(posts, &entry(site, &1))

    """
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
    <title>#{escape(site.title)}</title>
    #{subtitle(site)}<link href="#{Site.abs_url(site, "")}"/>
    <link rel="self" href="#{Site.abs_url(site, "feed.xml")}"/>
    <id>#{Site.abs_url(site, "")}</id>
    <updated>#{updated}</updated>
    <author><name>#{escape(site.author)}</name></author>
    #{entries}</feed>
    """
  end

  defp entry(site, post) do
    url = Site.abs_url(site, Document.rel_url(post.path))

    """
    <entry>
    <title>#{escape(post.meta.title)}</title>
    <link href="#{url}"/>
    <id>#{url}</id>
    <published>#{timestamp(post.meta.date)}</published>
    <updated>#{timestamp(post.meta.date)}</updated>
    #{summary(post)}<content type="html">#{escape(post.html)}</content>
    </entry>
    """
  end

  defp subtitle(%Site{description: nil}), do: ""
  defp subtitle(%Site{description: text}), do: "<subtitle>#{escape(text)}</subtitle>\n"

  defp summary(%Document{meta: %{description: text}}) when is_binary(text) do
    "<summary>#{escape(text)}</summary>\n"
  end

  defp summary(_post), do: ""

  defp feed_updated([]), do: timestamp(~D[1970-01-01])
  defp feed_updated([newest | _rest]), do: timestamp(newest.meta.date)

  defp timestamp(%Date{} = date), do: Date.to_iso8601(date) <> "T00:00:00Z"

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
