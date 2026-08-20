---
title: LLMs and SEO
description: Two kinds of readers hit your site now, crawlers and agents. How Cherry serves both from one build, and why doing it in the framework beats doing it in the theme.
tags:
  - design
  - elixir
---
A static site used to have one non-human audience: search crawlers. Now it has two. Agents and LLMs read sites to answer questions, summarise, quote, and act, and they are terrible at reading the same HTML your visitors enjoy. Cherry treats both audiences as build outputs. SEO and the machine surface are default-on, zero config, and generated from the same content pass as the human pages, so nothing can drift. This post shows how both halves are implemented, and why the boring choices are the ones that work.

## The head your theme cannot forget

The classic SEO failure mode is not a missing technique, it is a missing tag. Someone writes a lovely theme, forgets the canonical link, and every page competes with itself in the index. Cherry's answer is structural: the SEO head is framework-owned HTML, handed to the theme's layout as a single `@head_extra` assign. A theme renders it or fails the contract check. It cannot half-render it.

```elixir
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
```

Here is what that produces on the [search post](/search-without-node/), straight from the built page, with the long description attribute shortened to fit:

```html
<link rel="canonical" href="https://cherrybomb.dev/search-without-node/">
<link rel="alternate" type="application/atom+xml" title="CherryBomb" href="/feed.xml">
<link rel="alternate" type="application/feed+json" title="CherryBomb" href="/feed.json">
<link rel="icon" href="/favicon.ico" sizes="32x32">
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<meta name="description" content="Cherry's built-in search engine is an inverted index...">
<meta property="og:title" content="Search without Node">
<meta property="og:url" content="https://cherrybomb.dev/search-without-node/">
<meta property="og:site_name" content="CherryBomb">
<meta property="og:image" content="https://cherrybomb.dev/og-card.png">
<meta name="twitter:card" content="summary_large_image">
<meta property="og:type" content="article">
<meta property="article:published_time" content="2026-08-19">
```

Every line there is either table stakes (canonical, description, Open Graph) or discovery (feed links, icons). None of it is clever. The point is that the author wrote a `description:` line in frontmatter and the machine did the rest, on every page, forever.

One detail I like: the Twitter card type is decided honestly.

```elixir
# The 1200×630 social card earns the large-image card; without one,
# summary is the honest default.
defp twitter_card(%Site{social_image: nil}), do: "summary"
defp twitter_card(%Site{}), do: "summary_large_image"
```

Claiming `summary_large_image` without an image gets you a broken-looking embed. Cherry only claims what the site actually has.

## Structured data, because crawlers like JSON too

Posts additionally carry JSON-LD, the schema.org vocabulary search engines actually parse. It is built with the standard library's JSON encoder from the same frontmatter as everything else:

```elixir
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
```

The emitted tag is minified; pretty-printed, the payload on that same post reads:

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "Search without Node",
  "datePublished": "2026-08-19",
  "url": "https://cherrybomb.dev/search-without-node/",
  "keywords": ["elixir", "design"],
  "description": "Cherry's built-in search engine is an inverted index in pure Elixir and a 2KB client. Term weighting, plural folding, and a tokenizer that lives in two languages."
}
```

## Feeds, sitemap, robots: one stage, zero config

The rest of the crawler surface is a single pipeline stage. It emits an Atom feed, a JSON Feed, the sitemap, and `robots.txt`, and it runs after layout so the sitemap covers every page the build produced:

```elixir
pages = [
  %Page{source: ":feed", path: "feed.xml", content: Feed.render(site, posts)},
  %Page{source: ":json_feed", path: "feed.json", content: JsonFeed.render(site, posts)},
  %Page{source: ":sitemap", path: "sitemap.xml", content: sitemap(site, build.pages)},
  %Page{source: ":robots", path: "robots.txt", content: robots(site)}
]
```

The sitemap logic is three rejections and a sort: drop unlisted pages, drop `404.html`, sort for determinism, done. There is no `priority` tuning and no `changefreq` guessing, because search engines ignore both and honesty beats theatre.

## The other audience

Now the newer half. When an agent wants to know what is on your site, it has two bad options: scrape your HTML and hope the theme markup is guessable, or hit a search API and hope your site is indexed. [llms.txt](https://llmstxt.org) proposes a third: a markdown index at a well-known URL, written for machine consumption. Cherry emits one on every build:

```text
# CherryBomb

> Cherry is a static site generator for hackers, a modern take on Octopress.

## Blog

- [Blog](https://cherrybomb.dev/blog/index.md)
- [The embedded server](https://cherrybomb.dev/the-embedded-server/index.md) — 2026-08-19
- [Search without Node](https://cherrybomb.dev/search-without-node/index.md) — 2026-08-19

## Pages

- [About](https://cherrybomb.dev/about/index.md)
- [The CLI](https://cherrybomb.dev/docs/cli/index.md)
```

That is a trimmed excerpt of [this site's actual llms.txt](/llms.txt). Notice where the links point: not at the HTML pages, but at markdown twins.

## Markdown mirrors: the same page, minus the theme

Every content route Cherry emits carries an `index.md` alongside its `index.html`. Append `index.md` to any URL on this site, including this post, and you get the page as markdown: title, date, body, no navigation, no theme, no JavaScript. The generation is a comprehension over the documents the build already has in memory:

```elixir
# Raw documents have no markdown source; data-only documents (nil
# path) have no route. Everything else mirrors its own body.
defp document_mirrors(documents) do
  for %Document{raw?: false, path: path} = doc <- documents,
      is_binary(path) and String.ends_with?(path, "index.html") do
    %Mirror{path: mirror_path(path), markdown: document_markdown(doc)}
  end
end
```

This is the part worth stealing even if you never use Cherry. The mirror is not a converted copy of the HTML, and it is not a second rendering pipeline that someone has to keep in sync. Both surfaces derive from the same parsed document in the same build pass, so they cannot disagree. There is no cron job, no "regenerate the API docs" step, no staleness. If the HTML changed, the markdown changed, because they are two projections of one value.

The synthetic pages get mirrors too: the blog index, every tag page, the portfolio timeline, the CV. An agent can walk the whole site without parsing a single `<div>`.

## Ordering as a design decision

There is one subtlety, and it is my favourite kind: a correctness property enforced by pipeline order. The whole machine stage is twenty lines, and the interesting part is the comment:

```elixir
defmodule Cherry.Pipeline.Stages.Machine do
  @moduledoc """
  Appends the machine surface (DESIGN.md §6): markdown mirrors and
  `llms.txt`.

  Runs after `Feeds` on purpose — the sitemap and Atom feed describe
  the human site, so mirrors must not leak into them.
  """

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{} = build) do
    {:ok, %Build{build | pages: build.pages ++ Machine.pages(build)}}
  end
end
```

The sitemap is for crawlers indexing the human site, so it must not contain the mirrors. Rather than filtering mirror paths out of the sitemap, Cherry generates the sitemap before the mirrors exist. The invariant is free, and no future change to the sitemap code can break it.

Privacy composes the same way. A CV marked `unlisted` still gets its mirror, so the URL works when you share it, but the mirror never appears in `llms.txt`, the sitemap, or the feeds:

```elixir
# Only a public CV is announced; unlisted stays shareable but silent.
defp cv_section(site, %CV{profile: %{cv: %{visibility: :public}}}) do
  "\n## CV\n\n- [CV](#{Site.abs_url(site, "cv/index.md")})\n" <>
    "- [JSON Resume](#{Site.abs_url(site, "cv.json")})\n"
end

defp cv_section(_site, _cv), do: ""
```

One `visibility:` line in frontmatter, and every surface honours it, because every surface is generated from the same struct.

## Why this works

For crawlers, Cherry does nothing novel, and that is the point. Canonical URLs, descriptions, Open Graph, JSON-LD, feeds, a sitemap: this is the checklist every SEO audit produces, executed by a machine instead of remembered by an author. Consistency is the whole game. A site where every page has all of it beats a site where the important pages have most of it.

For agents, the win is bigger, because the baseline is worse. An LLM reading your HTML spends most of its attention discarding your theme. The same content as markdown is smaller, cleaner, and unambiguous, and `llms.txt` means the agent does not have to guess your URL structure to find it. When someone asks their assistant "how does Cherry's search work?", the assistant can fetch `/search-without-node/index.md` and get exactly the words I wrote, nothing else.

And because Cherry's builds are byte-deterministic, the machine surface is too: same content in, same `llms.txt` out, byte for byte. You can diff what agents see between deploys the same way you diff code.

The test for all of this is pleasingly self-referential. You are reading a page that carries its own mirror: [/llms-and-seo/index.md](/llms-and-seo/index.md). Go on, append `index.md` to the URL. Every page here does that.
