defmodule Cherry.Collections.Collection do
  @moduledoc """
  Behaviour for a content collection: directory + schema + routing (ADR 0003).

  `parse_source/2` lets a collection derive metadata from the file path
  itself (posts take their date and slug from `YYYY-MM-DD-slug.md`) before
  schema validation runs. `route/1` maps validated metadata to the
  output-relative destination file.
  """

  alias Cherry.Content.Document

  @doc "Directory relative to the site root, e.g. `content/posts`."
  @callback dir() :: String.t()

  @doc "The raw NimbleOptions-style schema keyword list (introspectable)."
  @callback schema() :: keyword()

  @doc "Derives metadata from the source path, merged under the frontmatter."
  @callback parse_source(String.t(), map()) :: {:ok, map()} | {:error, String.t()}

  @doc """
  Output-relative destination for a validated document, or `nil` for
  data-only collections (portfolio entries have no page of their own —
  the timeline, story, and CV views render them).
  """
  @callback route(Document.t()) :: String.t() | nil
end
