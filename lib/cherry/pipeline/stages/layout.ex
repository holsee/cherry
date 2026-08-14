defmodule Cherry.Pipeline.Stages.Layout do
  @moduledoc """
  Renders documents through the active theme into emit-ready pages, and
  generates the synthetic pages the contract owes every site: the post
  index (`/blog/`), one page per tag (`/blog/tags/:tag/`), `404.html`,
  and — when the site carries a portfolio — the timeline (`/portfolio/`)
  and one story page per portfolio tag (`/story/:tag/`).

  Raw documents keep their body verbatim; everything else renders via the
  three-level lookup (site overlay → theme → framework).
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.{Asset, Document, Page}
  alias Cherry.Portfolio
  alias Cherry.SEO.{Head, Person}
  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.{Helpers, NavItem, RenderContext, Renderer}

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()} | {:error, String.t()}
  def run(%Build{site: site} = build) do
    portfolio = Portfolio.from_build(build)

    with {:ok, theme} <- Theme.load_active(site),
         context = base_context(site, theme, portfolio),
         {:ok, content_pages} <- render_documents(build.documents, context),
         {:ok, synthetic} <- synthetic_pages(build.documents, portfolio, context) do
      assets = build.assets ++ theme_assets(theme)
      {:ok, %Build{build | pages: content_pages ++ synthetic, assets: assets}}
    end
  end

  defp base_context(site, theme, portfolio) do
    nav =
      [%NavItem{label: "Blog", href: Site.href(site, "blog/")}] ++
        if Portfolio.present?(portfolio) do
          [%NavItem{label: "Portfolio", href: Site.href(site, "portfolio/")}]
        else
          []
        end

    %RenderContext{site: site, theme: theme, nav: nav}
  end

  # The theme's static files (CSS, compiled islands) ship under /assets/.
  defp theme_assets(theme) do
    # Path.wildcard/1 treats backslashes as escape characters, so a Windows
    # theme root silently matches nothing.
    base = theme.root |> Path.join("assets") |> String.replace("\\", "/")

    base
    |> Path.join("**")
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> Enum.sort()
    |> Enum.map(fn abs ->
      rel = abs |> Path.relative_to(base) |> String.replace("\\", "/")
      %Asset{source: abs, path: "assets/" <> rel}
    end)
  end

  defp render_documents(documents, context) do
    documents
    # Data-only documents (nil path) are rendered by views, not as pages.
    |> Enum.reject(&is_nil(&1.path))
    |> map_while_ok(fn doc -> render_document(doc, context) end)
  end

  defp render_document(%Document{raw?: true} = doc, _context) do
    {:ok, %Page{source: doc.source, path: doc.path, content: doc.body}}
  end

  defp render_document(%Document{} = doc, context) do
    template = template_for(doc.collection)
    title = Map.get(doc.meta, :title, context.site.title)
    page_context = RenderContext.page(context, title, Head.for_document(context.site, doc))

    with {:ok, html} <-
           Renderer.render_in_layout(page_context, template, site: context.site, doc: doc) do
      {:ok, %Page{source: doc.source, path: doc.path, content: html}}
    end
  end

  defp synthetic_pages(documents, portfolio, context) do
    posts = posts_newest_first(documents)

    with {:ok, index} <- post_index(posts, context),
         {:ok, tag_pages} <- tag_pages(posts, portfolio, context),
         {:ok, portfolio_pages} <- portfolio_pages(portfolio, posts, context),
         {:ok, not_found} <- not_found(context) do
      {:ok, [index | tag_pages] ++ portfolio_pages ++ [not_found]}
    end
  end

  defp post_index(posts, context) do
    path = "blog/index.html"
    page_context = RenderContext.page(context, "Blog", Head.for_page(context.site, "Blog", path))

    with {:ok, html} <-
           Renderer.render_in_layout(page_context, :post_list, site: context.site, posts: posts) do
      {:ok, %Page{source: ":post_list", path: path, content: html}}
    end
  end

  defp tag_pages(posts, portfolio, context) do
    story_tags = MapSet.new(Portfolio.tags(portfolio))

    posts
    |> Enum.flat_map(fn post -> Enum.map(post.meta.tags, &{Helpers.tag_slug(&1), &1}) end)
    |> Enum.uniq_by(fn {slug, _tag} -> slug end)
    |> Enum.sort()
    |> map_while_ok(fn {slug, tag} ->
      tagged = Enum.filter(posts, fn post -> tag in post.meta.tags end)
      title = "Tagged: #{tag}"
      path = Path.join(["blog", "tags", slug, "index.html"])

      story_href =
        if MapSet.member?(story_tags, tag) do
          Site.href(context.site, "story/#{slug}/")
        end

      assigns = [site: context.site, tag: tag, posts: tagged, story_href: story_href]
      page_context = RenderContext.page(context, title, Head.for_page(context.site, title, path))

      with {:ok, html} <- Renderer.render_in_layout(page_context, :tag, assigns) do
        {:ok, %Page{source: ":tag", path: path, content: html}}
      end
    end)
  end

  defp portfolio_pages(portfolio, posts, context) do
    if Portfolio.present?(portfolio) do
      with {:ok, timeline} <- timeline_page(portfolio, context),
           {:ok, stories} <- story_pages(portfolio, posts, context) do
        {:ok, [timeline | stories]}
      end
    else
      {:ok, []}
    end
  end

  defp timeline_page(portfolio, context) do
    path = "portfolio/index.html"

    head =
      Head.for_page(context.site, "Portfolio", path) <> Person.json_ld(context.site, portfolio)

    page_context = RenderContext.page(context, "Portfolio", head)
    assigns = [site: context.site, portfolio: portfolio]

    with {:ok, html} <- Renderer.render_in_layout(page_context, :portfolio_timeline, assigns) do
      {:ok, %Page{source: ":portfolio_timeline", path: path, content: html}}
    end
  end

  defp story_pages(portfolio, posts, context) do
    portfolio
    |> Portfolio.tags()
    |> map_while_ok(fn tag ->
      slug = Helpers.tag_slug(tag)
      path = Path.join(["story", slug, "index.html"])
      title = "The #{tag} story"
      tagged_posts = Enum.filter(posts, fn post -> tag in post.meta.tags end)

      assigns = [
        site: context.site,
        tag: tag,
        portfolio: Portfolio.filter_by_tag(portfolio, tag),
        posts: tagged_posts
      ]

      page_context = RenderContext.page(context, title, Head.for_page(context.site, title, path))

      with {:ok, html} <- Renderer.render_in_layout(page_context, :story, assigns) do
        {:ok, %Page{source: ":story", path: path, content: html}}
      end
    end)
  end

  # The 404 page gets no SEO head: it serves at arbitrary URLs, so a
  # canonical link or Open Graph URL would always be wrong.
  defp not_found(context) do
    page_context = RenderContext.page(context, "Page not found", "")

    with {:ok, html} <- Renderer.render_in_layout(page_context, :not_found, site: context.site) do
      {:ok, %Page{source: ":not_found", path: "404.html", content: html}}
    end
  end

  defp posts_newest_first(documents) do
    documents
    |> Enum.filter(&(&1.collection == "posts" and not &1.raw?))
    |> Enum.sort_by(&{&1.meta.date, &1.meta.slug}, :desc)
  end

  defp template_for("posts"), do: :post
  defp template_for(_collection), do: :page

  defp map_while_ok(enum, fun) do
    Enum.reduce_while(enum, {:ok, []}, fn item, {:ok, acc} ->
      case fun.(item) do
        {:ok, value} -> {:cont, {:ok, [value | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, values} -> {:ok, Enum.reverse(values)}
      {:error, reason} -> {:error, reason}
    end
  end
end
