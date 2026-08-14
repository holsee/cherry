defmodule Cherry.Content.Asset do
  @moduledoc """
  A static file copied verbatim into the output tree.

  `path` is the output-relative destination; `source` is the absolute file
  it is copied from. Assets never pass through transforms — that is what
  makes them assets.
  """

  @enforce_keys [:source, :path]
  defstruct [:source, :path]

  @type t :: %__MODULE__{
          source: Path.t(),
          path: String.t()
        }
end
