defmodule Cherry.Content.Page do
  @moduledoc """
  A page travelling through the build pipeline.

  `path` is the output-relative destination (always forward-slashed);
  `source` is the content file it came from, relative to the site root.
  `unlisted?` pages are emitted but stay out of the sitemap (the
  unlisted CV: shareable by URL, announced nowhere).
  """

  @enforce_keys [:source, :path, :content]
  defstruct [:source, :path, :content, unlisted?: false]

  @type t :: %__MODULE__{
          source: String.t(),
          path: String.t(),
          content: binary(),
          unlisted?: boolean()
        }
end
