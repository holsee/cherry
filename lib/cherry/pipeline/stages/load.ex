defmodule Cherry.Pipeline.Stages.Load do
  @moduledoc """
  Reads content and static files from the site root into the token.

  For now pages are `content/pages/**` verbatim and assets are `static/**`;
  frontmatter parsing and collections replace the page half in a later slice.
  File lists are sorted so the token (and everything downstream) is
  order-deterministic regardless of filesystem enumeration.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.{Asset, Page}

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{site: site} = build) do
    pages =
      site.root
      |> files_under("content/pages")
      |> Enum.map(fn {abs, rel} ->
        %Page{
          source: join_url("content/pages", rel),
          path: rel,
          content: File.read!(abs)
        }
      end)

    assets =
      site.root
      |> files_under("static")
      |> Enum.map(fn {abs, rel} -> %Asset{source: abs, path: rel} end)

    {:ok, %Build{build | pages: pages, assets: assets}}
  end

  defp files_under(root, subdir) do
    base = Path.join(root, subdir)

    base
    |> Path.join("**")
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&{&1, Path.relative_to(&1, base)})
    |> Enum.sort_by(fn {_abs, rel} -> rel end)
  end

  defp join_url(prefix, rel), do: prefix <> "/" <> rel
end
