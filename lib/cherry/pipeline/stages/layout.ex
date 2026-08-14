defmodule Cherry.Pipeline.Stages.Layout do
  @moduledoc """
  Converts documents into emit-ready pages.

  Until the theme contract lands (DO_NEXT slice 5) the layout is a minimal,
  valid HTML5 shell — unstyled but correct. Raw documents keep their body
  verbatim.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.{Document, Page}

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{site: site} = build) do
    pages = Enum.map(build.documents, &to_page(&1, site))
    {:ok, %Build{build | pages: pages}}
  end

  defp to_page(%Document{raw?: true} = doc, _site) do
    %Page{source: doc.source, path: doc.path, content: doc.body}
  end

  defp to_page(%Document{} = doc, site) do
    title = escape(Map.get(doc.meta, :title, site.title))

    content = """
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#{title} · #{escape(site.title)}</title>
    </head>
    <body>
    #{doc.html}</body>
    </html>
    """

    %Page{source: doc.source, path: doc.path, content: content}
  end

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
