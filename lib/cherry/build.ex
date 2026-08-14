defmodule Cherry.Build do
  @moduledoc """
  The build token: the single value every pipeline stage takes and returns
  (Tableau's proven shape). Stages are pure `token -> token` transformations;
  only `load` and `emit` touch the filesystem.
  """

  alias Cherry.Content.{Asset, Page}
  alias Cherry.Site

  @enforce_keys [:site]
  defstruct site: nil, pages: [], assets: []

  @type t :: %__MODULE__{
          site: Site.t(),
          pages: [Page.t()],
          assets: [Asset.t()]
        }

  @doc "Starts a build token from a loaded site."
  @spec new(Site.t()) :: t()
  def new(%Site{} = site), do: %__MODULE__{site: site}
end
