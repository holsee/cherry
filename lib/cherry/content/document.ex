defmodule Cherry.Content.Document do
  @moduledoc """
  A content file travelling through the pipeline: parsed, not yet emitted.

  `meta` holds schema-validated frontmatter (atom keys). `body` is the raw
  source body; `html` is filled by the transform stage. `raw?` marks bare
  `.html` pages that bypass validation, transform, and layout entirely — the
  escape hatch for hand-authored files.
  """

  @enforce_keys [:collection, :source]
  defstruct collection: nil,
            source: nil,
            meta: %{},
            body: "",
            html: nil,
            path: nil,
            raw?: false

  @type t :: %__MODULE__{
          collection: String.t(),
          source: String.t(),
          meta: map(),
          body: String.t(),
          html: String.t() | nil,
          path: String.t() | nil,
          raw?: boolean()
        }
end
