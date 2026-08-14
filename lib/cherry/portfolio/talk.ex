defmodule Cherry.Portfolio.Talk do
  @moduledoc "A talk given at an event, with the recording and slides."

  alias Cherry.Content.Document
  alias Cherry.Portfolio.Curation

  @enforce_keys [:slug, :title, :event, :date]
  defstruct [:slug, :title, :event, :date, :video, :slides, :cv, :html, tags: [], highlights: []]

  @type t :: %__MODULE__{
          slug: String.t(),
          title: String.t(),
          event: String.t(),
          date: Date.t(),
          video: String.t() | nil,
          slides: String.t() | nil,
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
      event: meta.event,
      date: meta.date,
      video: meta[:video],
      slides: meta[:slides],
      tags: meta.tags,
      highlights: meta.highlights,
      cv: meta[:cv],
      html: html
    }
  end

  @doc "Newest-first ordering by date."
  @spec sort_key(t()) :: Date.t()
  def sort_key(%__MODULE__{date: date}), do: date
end
