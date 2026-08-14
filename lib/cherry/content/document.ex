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
            url: nil,
            raw?: false

  @type t :: %__MODULE__{
          collection: String.t(),
          source: String.t(),
          meta: map(),
          body: String.t(),
          html: String.t() | nil,
          path: String.t() | nil,
          url: String.t() | nil,
          raw?: boolean()
        }

  @doc "Root-relative URL for an output path: `about/index.html` → `/about/`."
  @spec url_for(String.t()) :: String.t()
  def url_for(path) do
    case String.trim_trailing(path, "index.html") do
      "" -> "/"
      trimmed -> "/" <> trimmed
    end
  end
end
