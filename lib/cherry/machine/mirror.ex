defmodule Cherry.Machine.Mirror do
  @moduledoc """
  One markdown mirror: the `index.md` twin a route directory carries
  alongside its `index.html` (DESIGN.md §6), so agents read content
  without scraping HTML.

  `unlisted?` rides along from the mirrored page — an unlisted CV's
  mirror exists at its URL but stays out of `llms.txt`.
  """

  alias Cherry.Content.Page

  @enforce_keys [:path, :markdown]
  defstruct [:path, :markdown, unlisted?: false]

  @type t :: %__MODULE__{
          path: String.t(),
          markdown: String.t(),
          unlisted?: boolean()
        }

  @doc "The emit-ready page for a mirror."
  @spec to_page(t()) :: Page.t()
  def to_page(%__MODULE__{} = mirror) do
    %Page{
      source: ":mirror",
      path: mirror.path,
      content: mirror.markdown,
      unlisted?: mirror.unlisted?
    }
  end
end
