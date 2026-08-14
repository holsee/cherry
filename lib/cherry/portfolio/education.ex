defmodule Cherry.Portfolio.Education do
  @moduledoc "A qualification: degree, certification, or formal course."

  alias Cherry.Content.Document
  alias Cherry.Portfolio.Curation

  @enforce_keys [:slug, :title, :institution]
  defstruct [:slug, :title, :institution, :started, :ended, :cv, :html, tags: [], highlights: []]

  @type t :: %__MODULE__{
          slug: String.t(),
          title: String.t(),
          institution: String.t(),
          started: Date.t() | nil,
          ended: Date.t() | nil,
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
      institution: meta.institution,
      started: meta[:start],
      ended: meta[:end],
      tags: meta.tags,
      highlights: meta.highlights,
      cv: meta[:cv],
      html: html
    }
  end

  @doc "Newest-first ordering by completion, then start."
  @spec sort_key(t()) :: {Date.t(), Date.t()}
  def sort_key(%__MODULE__{} = education) do
    {education.ended || ~D[9999-12-31], education.started || ~D[0001-01-01]}
  end
end
