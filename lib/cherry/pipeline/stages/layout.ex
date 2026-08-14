defmodule Cherry.Pipeline.Stages.Layout do
  @moduledoc """
  Renders documents through the active theme into emit-ready pages, and
  generates the synthetic pages the contract owes every site: the post
  index (`/blog/`), one page per tag (`/blog/tags/:tag/`), and `404.html`.

  Raw documents keep their body verbatim; everything else renders via the
  three-level lookup (site overlay → theme → framework).
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.{Document, Page}
  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.{Helpers, Renderer}

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()} | {:error, String.t()}
  def run(%Build{site: site} = build) do
    with {:ok, theme} <- Theme.load_active(site),
         {:ok, content_pages} <- render_documents(build.documents, site, theme),
         {:ok, synthetic} <- synthetic_pages(build.documents, site, theme) do
      {:ok, %Build{build | pages: content_pages ++ synthetic}}
    end
  end

  defp render_documents(documents, site, theme) do
    documents
    |> map_while_ok(fn doc -> render_document(doc, site, theme) end)
  end

  defp render_document(%Document{raw?: true} = doc, _site, _theme) do
    {:ok, %Page{source: doc.source, path: doc.path, content: doc.body}}
  end

  defp render_document(%Document{} = doc, site, theme) do
    template = template_for(doc.collection)
    title = Map.get(doc.meta, :title, site.title)

    with {:ok, html} <-
           Renderer.render_in_layout(site, theme, template, [site: site, doc: doc], title) do
      {:ok, %Page{source: doc.source, path: doc.path, content: html}}
    end
  end

  defp synthetic_pages(documents, site, theme) do
    posts = posts_newest_first(documents)

    with {:ok, index} <- post_index(posts, site, theme),
         {:ok, tag_pages} <- tag_pages(posts, site, theme),
         {:ok, not_found} <- not_found(site, theme) do
      {:ok, [index | tag_pages] ++ [not_found]}
    end
  end

  defp post_index(posts, site, theme) do
    with {:ok, html} <-
           Renderer.render_in_layout(site, theme, :post_list, [site: site, posts: posts], "Blog") do
      {:ok, %Page{source: ":post_list", path: "blog/index.html", content: html}}
    end
  end

  defp tag_pages(posts, site, theme) do
    posts
    |> Enum.flat_map(fn post -> Enum.map(post.meta.tags, &{Helpers.tag_slug(&1), &1}) end)
    |> Enum.uniq_by(fn {slug, _tag} -> slug end)
    |> Enum.sort()
    |> map_while_ok(fn {slug, tag} ->
      tagged = Enum.filter(posts, fn post -> tag in post.meta.tags end)
      assigns = [site: site, tag: tag, posts: tagged]

      with {:ok, html} <-
             Renderer.render_in_layout(site, theme, :tag, assigns, "Tagged: #{tag}") do
        {:ok,
         %Page{
           source: ":tag",
           path: Path.join(["blog", "tags", slug, "index.html"]),
           content: html
         }}
      end
    end)
  end

  defp not_found(%Site{} = site, theme) do
    with {:ok, html} <-
           Renderer.render_in_layout(site, theme, :not_found, [site: site], "Page not found") do
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
