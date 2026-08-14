defmodule Cherry.SEO.Head do
  @moduledoc """
  Builds the SEO `<head>` block every page carries: canonical link, feed
  discovery, meta description, Open Graph / Twitter cards, and JSON-LD
  `BlogPosting` for posts.

  This is framework-owned HTML handed to the theme's layout as
  `@head_extra` — SEO is default-on and a theme cannot forget it.
  """

  alias Cherry.Content.Document
  alias Cherry.Site

  @doc "Head block for a content document."
  @spec for_document(Site.t(), Document.t()) :: String.t()
  def for_document(%Site{} = site, %Document{} = doc) do
    rel = Document.rel_url(doc.path)
    title = Map.get(doc.meta, :title, site.title)
    description = Map.get(doc.meta, :description) || site.description

    common(site, rel, title, description) <>
      if doc.collection == "posts" do
        post_extras(site, doc, rel, title, description)
      else
        ~s(<meta property="og:type" content="website">\n)
      end
  end

  @doc "Head block for a synthetic page (blog index, tag pages, 404)."
  @spec for_page(Site.t(), String.t(), String.t()) :: String.t()
  def for_page(%Site{} = site, title, path) do
    rel = Document.rel_url(path)

    common(site, rel, title, site.description) <>
      ~s(<meta property="og:type" content="website">\n)
  end

  defp common(site, rel, title, description) do
    canonical = Site.abs_url(site, rel)

    [
      ~s(<link rel="canonical" href="#{canonical}">\n),
      ~s(<link rel="alternate" type="application/atom+xml" title="#{escape(site.title)}" href="#{Site.href(site, "feed.xml")}">\n),
      ~s(<link rel="alternate" type="application/feed+json" title="#{escape(site.title)}" href="#{Site.href(site, "feed.json")}">\n),
      description_tag(description),
      ~s(<meta property="og:title" content="#{escape(title)}">\n),
      ~s(<meta property="og:url" content="#{canonical}">\n),
      ~s(<meta property="og:site_name" content="#{escape(site.title)}">\n),
      social_image(site),
      ~s(<meta name="twitter:card" content="summary">\n)
    ]
    |> IO.iodata_to_binary()
  end

  defp post_extras(site, doc, rel, title, description) do
    json_ld =
      JSON.encode!(
        %{
          "@context" => "https://schema.org",
          "@type" => "BlogPosting",
          "headline" => title,
          "datePublished" => Date.to_iso8601(doc.meta.date),
          "url" => Site.abs_url(site, rel),
          "keywords" => doc.meta.tags
        }
        |> maybe_put("description", description)
      )

    ~s(<meta property="og:type" content="article">\n) <>
      ~s(<meta property="article:published_time" content="#{Date.to_iso8601(doc.meta.date)}">\n) <>
      ~s(<script type="application/ld+json">#{json_ld}</script>\n)
  end

  defp description_tag(nil), do: ""

  defp description_tag(description) do
    ~s(<meta name="description" content="#{escape(description)}">\n) <>
      ~s(<meta property="og:description" content="#{escape(description)}">\n)
  end

  defp social_image(%Site{social_image: nil}), do: ""

  defp social_image(%Site{social_image: image} = site) do
    ~s(<meta property="og:image" content="#{Site.abs_url(site, image)}">\n)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end
