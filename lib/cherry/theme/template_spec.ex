defmodule Cherry.Theme.TemplateSpec do
  @moduledoc """
  One entry in a theme's template inventory: the template's name, the
  assigns it receives, and what it is for. Fixed names and fixed assigns
  are the contract that makes theme swapping real.
  """

  @enforce_keys [:name]
  defstruct name: nil, assigns: [], doc: nil

  @type t :: %__MODULE__{
          name: atom(),
          assigns: [atom()],
          doc: String.t() | nil
        }

  @doc "Parses the manifest's `templates:` keyword list into specs."
  @spec from_manifest(keyword()) :: [t()]
  def from_manifest(entries) do
    Enum.map(entries, fn {name, spec} ->
      %__MODULE__{
        name: name,
        assigns: Keyword.get(spec, :assigns, []),
        doc: Keyword.get(spec, :doc)
      }
    end)
  end
end
