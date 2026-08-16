defmodule Cherry.Pipeline.Stages.Search do
  @moduledoc """
  Emits the runtime for `search: "cherry"`, Cherry's built-in search
  engine: `search/index.json` and the `search/search.js` island.

  Unlike `Stages.Post` — which shells out to Pagefind — this stage is a
  pure function of the parsed documents, so it runs anywhere cherry
  itself runs and lands inside the deterministic build.

  The island ships from here rather than from each theme's `assets/`,
  so any theme, including one a site wrote itself, gets a working
  search box by rendering the markup and pointing at these paths.

  Runs after `Machine` and before `Emit`: the index is a runtime data
  file, not part of the human site or the machine surface, so it stays
  out of the sitemap, the feeds, and `llms.txt`.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.Page
  alias Cherry.Search.Index
  alias Cherry.Site

  @index_path "search/index.json"
  @script_path "search/search.js"

  # Compiled from assets/js/search.ts by `npm run build` and committed,
  # so a released binary carries the island as bytes — the same trick
  # `Cherry.Serve.Plug` uses for livereload.
  @external_resource "priv/search/search.js"
  @script File.read!("priv/search/search.js")

  @doc "Output path of the emitted index."
  @spec index_path() :: String.t()
  def index_path, do: @index_path

  @doc "Output path of the emitted search island."
  @spec script_path() :: String.t()
  def script_path, do: @script_path

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{site: %Site{search: "cherry"} = site} = build) do
    pages = [
      %Page{
        source: ":search_index",
        path: @index_path,
        content: Index.render(build.documents, site),
        unlisted?: true
      },
      %Page{source: ":search_island", path: @script_path, content: @script, unlisted?: true}
    ]

    {:ok, %Build{build | pages: build.pages ++ pages}}
  end

  def run(%Build{} = build), do: {:ok, build}
end
