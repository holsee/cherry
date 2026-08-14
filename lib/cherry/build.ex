defmodule Cherry.Build do
  @moduledoc """
  The build token: the single value every pipeline stage takes and returns
  (Tableau's proven shape). Stages are pure `token -> token` transformations;
  only `load` and `emit` touch the filesystem.

  `documents` are parsed content on their way to becoming `pages` (the
  layout stage performs that conversion); `assets` copy through untouched.
  """

  alias Cherry.Build.Options
  alias Cherry.Content.{Asset, Document, Page}
  alias Cherry.Site

  @enforce_keys [:site, :options]
  defstruct site: nil, options: nil, documents: [], pages: [], assets: []

  @type t :: %__MODULE__{
          site: Site.t(),
          options: Options.t(),
          documents: [Document.t()],
          pages: [Page.t()],
          assets: [Asset.t()]
        }

  @doc "Starts a build token from a loaded site and build options."
  @spec new(Site.t(), Options.t()) :: t()
  def new(%Site{} = site, %Options{} = options) do
    %__MODULE__{site: site, options: options}
  end
end
