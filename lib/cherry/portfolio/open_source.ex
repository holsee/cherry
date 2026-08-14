defmodule Cherry.Portfolio.OpenSource do
  @moduledoc "An open-source involvement: repository plus named role."

  alias Cherry.Content.Document
  alias Cherry.Portfolio.CV

  @enforce_keys [:slug, :title, :repo, :role]
  defstruct [:slug, :title, :repo, :role, :cv, :html, tags: [], highlights: []]

  @type t :: %__MODULE__{
          slug: String.t(),
          title: String.t(),
          repo: String.t(),
          role: String.t(),
          tags: [String.t()],
          highlights: [String.t()],
          cv: CV.t() | nil,
          html: String.t() | nil
        }

  @doc "Materialises the struct from a validated portfolio document."
  @spec from_document(Document.t()) :: t()
  def from_document(%Document{meta: meta, html: html}) do
    %__MODULE__{
      slug: meta.slug,
      title: meta.title,
      repo: meta.repo,
      role: meta.role,
      tags: meta.tags,
      highlights: meta.highlights,
      cv: meta[:cv],
      html: html
    }
  end

  @doc "Stable ordering: authored work first, then by title."
  @spec sort_key(t()) :: {integer(), String.t()}
  def sort_key(%__MODULE__{} = oss) do
    role_rank = %{"author" => 0, "maintainer" => 1, "contributor" => 2}
    # :desc sort — negate the rank so authors still lead.
    {-Map.fetch!(role_rank, oss.role), oss.title}
  end
end
