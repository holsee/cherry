defmodule Cherry.Portfolio do
  @moduledoc """
  The developer story as typed data: the profile plus every portfolio
  entry, materialised from a finished build token.

  This is the seam the views stand on — timeline, story pages, and the
  CV all consume `%Portfolio{}`, never raw documents, so the shape of
  an entry is a named struct with real fields, not a frontmatter map.
  """

  alias Cherry.Build
  alias Cherry.Content.Document
  alias Cherry.Portfolio.{Education, OpenSource, Position, Profile, Project, Talk}

  defstruct profile: nil, positions: [], projects: [], talks: [], oss: [], education: []

  @type t :: %__MODULE__{
          profile: Profile.t() | nil,
          positions: [Position.t()],
          projects: [Project.t()],
          talks: [Talk.t()],
          oss: [OpenSource.t()],
          education: [Education.t()]
        }

  @entry_modules %{
    "portfolio/positions" => Position,
    "portfolio/projects" => Project,
    "portfolio/talks" => Talk,
    "portfolio/oss" => OpenSource,
    "portfolio/education" => Education
  }

  @doc """
  Builds the typed portfolio from a build token; entries come out
  newest-first within their collection.
  """
  @spec from_build(Build.t()) :: t()
  def from_build(%Build{} = build) do
    entries =
      build.documents
      |> Enum.filter(&Map.has_key?(@entry_modules, &1.collection))
      |> Enum.group_by(& &1.collection)
      |> Map.new(fn {collection, documents} ->
        module = Map.fetch!(@entry_modules, collection)

        typed =
          documents
          |> Enum.map(&module.from_document/1)
          |> Enum.sort_by(&module.sort_key/1, :desc)

        {collection, typed}
      end)

    %__MODULE__{
      profile: build.profile,
      positions: Map.get(entries, "portfolio/positions", []),
      projects: Map.get(entries, "portfolio/projects", []),
      talks: Map.get(entries, "portfolio/talks", []),
      oss: Map.get(entries, "portfolio/oss", []),
      education: Map.get(entries, "portfolio/education", [])
    }
  end

  @doc "True when the site carries any portfolio content at all."
  @spec present?(t()) :: boolean()
  def present?(%__MODULE__{} = portfolio) do
    portfolio.profile != nil or
      Enum.any?(
        [
          portfolio.positions,
          portfolio.projects,
          portfolio.talks,
          portfolio.oss,
          portfolio.education
        ],
        &(&1 != [])
      )
  end

  @doc "Every entry across collections, for taxonomy and freshness scans."
  @spec entries(t()) :: [struct()]
  def entries(%__MODULE__{} = portfolio) do
    portfolio.positions ++
      portfolio.projects ++ portfolio.talks ++ portfolio.oss ++ portfolio.education
  end

  @doc "True when the document belongs to a portfolio collection."
  @spec entry_document?(Document.t()) :: boolean()
  def entry_document?(%Document{collection: collection}) do
    Map.has_key?(@entry_modules, collection)
  end
end
