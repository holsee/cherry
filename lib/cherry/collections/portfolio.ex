defmodule Cherry.Collections.Portfolio do
  @moduledoc """
  Shared shape of the portfolio collections (DESIGN.md §4): typed entries
  under `content/portfolio/`, slug from the filename, no page of their
  own — the timeline, story, and CV views render them.

  Every entry carries `tags:` from the same taxonomy as blog posts
  (the cross-linking is the feature) and may opt into the CV with a
  `cv:` curation block.
  """

  alias Cherry.Collections.Types

  @doc "Derives `slug` from the filename: `acme.md` → `acme`."
  @spec parse_source(String.t(), map()) :: {:ok, map()}
  def parse_source(rel_path, meta) do
    slug = rel_path |> Path.basename() |> Path.rootname()
    {:ok, Map.merge(%{"slug" => slug}, meta)}
  end

  @doc "Schema fields every portfolio collection shares."
  @spec common_fields() :: keyword()
  def common_fields do
    [
      slug: [type: :string, doc: "URL-safe identifier; defaults to the filename."],
      tags: [
        type: {:list, :string},
        default: [],
        doc: "Tags from the shared site taxonomy (cross-linked with blog posts)."
      ],
      highlights: [
        type: {:list, :string},
        default: [],
        doc: "Short bullet points for the timeline entry."
      ],
      cv: [
        type: {:custom, Types, :validate_cv, []},
        doc: "CV curation: `{include, weight, highlights}`. Absent → timeline-only."
      ],
      draft: [type: :boolean, default: false, doc: "Drafts are skipped unless `--drafts`."]
    ]
  end

  @doc "A required/optional ISO date field."
  @spec date_field(String.t(), keyword()) :: keyword()
  def date_field(doc, opts \\ []) do
    Keyword.merge([type: {:custom, Types, :validate_date, []}, doc: doc], opts)
  end
end
