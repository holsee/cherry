defmodule Cherry.Portfolio.Position do
  @moduledoc "An employment position on the timeline; open `ended` means current."

  alias Cherry.Content.Document
  alias Cherry.Portfolio.Curation

  @enforce_keys [:slug, :title, :org, :started]
  defstruct [
    :slug,
    :title,
    :org,
    :started,
    :ended,
    :location,
    :cv,
    :html,
    tags: [],
    highlights: []
  ]

  @type t :: %__MODULE__{
          slug: String.t(),
          title: String.t(),
          org: String.t(),
          started: Date.t(),
          ended: Date.t() | nil,
          location: String.t() | nil,
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
      org: meta.org,
      started: meta.start,
      ended: meta[:end],
      location: meta[:location],
      tags: meta.tags,
      highlights: meta.highlights,
      cv: meta[:cv],
      html: html
    }
  end

  @doc "Newest-first ordering: current positions rank above ended ones."
  @spec sort_key(t()) :: {:calendar.date(), :calendar.date()}
  def sort_key(%__MODULE__{} = position) do
    # Date.to_erl: %Date{} structs term-compare field-alphabetically
    # (day before year), so raw dates in sort keys order wrongly.
    {Date.to_erl(position.ended || ~D[9999-12-31]), Date.to_erl(position.started)}
  end

  @doc "True while the position has no end date."
  @spec current?(t()) :: boolean()
  def current?(%__MODULE__{ended: ended}), do: is_nil(ended)
end
