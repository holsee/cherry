defmodule Cherry.Content.Page do
  @moduledoc """
  A page travelling through the build pipeline.

  `path` is the output-relative destination (always forward-slashed);
  `source` is the content file it came from, relative to the site root.
  Collections and frontmatter arrive in a later slice — for now a page is
  content plus its two paths.
  """

  @enforce_keys [:source, :path, :content]
  defstruct [:source, :path, :content]

  @type t :: %__MODULE__{
          source: String.t(),
          path: String.t(),
          content: binary()
        }
end
