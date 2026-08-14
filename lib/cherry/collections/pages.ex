defmodule Cherry.Collections.Pages do
  @moduledoc """
  Freeform pages: `content/pages/**`.

  Markdown pages carry frontmatter and get pretty URLs (`about.md` →
  `about/index.html`; a root `index.md` stays `index.html`). `permalink:`
  overrides the derived route. Bare `.html` files without frontmatter are
  emitted verbatim at their own relative path (handled in the load stage).
  """

  @behaviour Cherry.Collections.Collection

  alias Cherry.Content.Document

  @impl Cherry.Collections.Collection
  @spec dir() :: String.t()
  def dir, do: "content/pages"

  @impl Cherry.Collections.Collection
  @spec schema() :: keyword()
  def schema do
    [
      title: [type: :string, required: true, doc: "Page title."],
      description: [type: :string, doc: "Meta description for SEO."],
      permalink: [
        type: :string,
        doc: "Explicit URL path like `/about/`; overrides the path-derived route."
      ]
    ]
  end

  @impl Cherry.Collections.Collection
  @spec parse_source(String.t(), map()) :: {:ok, map()}
  def parse_source(_rel_path, meta), do: {:ok, meta}

  @impl Cherry.Collections.Collection
  @spec route(Document.t()) :: String.t()
  def route(%Document{meta: %{permalink: permalink}}) when is_binary(permalink) do
    permalink |> String.trim("/") |> Path.join("index.html")
  end

  def route(%Document{source: source}) do
    rel = source |> Path.relative_to(dir()) |> Path.rootname()

    case rel do
      "index" -> "index.html"
      other -> Path.join(other, "index.html")
    end
  end
end
