defmodule Cherry.Portfolio.Project do
  @moduledoc "A project entry: something built, with links and a status."

  alias Cherry.Content.Document
  alias Cherry.Portfolio.{Curation, Link}

  @enforce_keys [:slug, :title, :status]
  defstruct [
    :slug,
    :title,
    :status,
    :started,
    :ended,
    :cv,
    :html,
    links: [],
    tags: [],
    highlights: []
  ]

  @type t :: %__MODULE__{
          slug: String.t(),
          title: String.t(),
          status: String.t(),
          started: Date.t() | nil,
          ended: Date.t() | nil,
          links: [Link.t()],
          tags: [String.t()],
          highlights: [String.t()],
          cv: Curation.t() | nil,
          html: String.t() | nil
        }

  @doc "Materialises the struct from a validated portfolio document."
  @spec from_document(Document.t()) :: t()
  def from_document(%Document{meta: meta, html: html}) do
    %__MODULE__{
      slug: meta.slug,
      title: meta.title,
      status: meta.status,
      started: meta[:start],
      ended: meta[:end],
      links: meta.links,
      tags: meta.tags,
      highlights: meta.highlights,
      cv: meta[:cv],
      html: html
    }
  end

  @doc "Newest-first ordering: active projects rank above finished ones."
  @spec sort_key(t()) :: {:calendar.date(), :calendar.date()}
  def sort_key(%__MODULE__{} = project) do
    {Date.to_erl(project.ended || ~D[9999-12-31]), Date.to_erl(project.started || ~D[0001-01-01])}
  end
end
