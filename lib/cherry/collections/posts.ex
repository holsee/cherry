defmodule Cherry.Collections.Posts do
  @moduledoc """
  Dated blog posts: `content/posts/YYYY-MM-DD-slug.md`.

  The filename is the source of truth for date and slug; a `date:` in
  frontmatter overrides the filename date. Default permalink is `/:slug/`
  (matching the old Octopress site so migrated URLs survive). Drafts and
  future-dated posts are filtered at build time unless `--drafts` /
  `--future` are given.
  """

  @behaviour Cherry.Collections.Collection

  alias Cherry.Collections.Types
  alias Cherry.Content.Document

  @filename ~r/\A(\d{4}-\d{2}-\d{2})-(.+)\.md\z/

  @impl Cherry.Collections.Collection
  @spec dir() :: String.t()
  def dir, do: "content/posts"

  @impl Cherry.Collections.Collection
  @spec schema() :: keyword()
  def schema do
    [
      title: [type: :string, required: true, doc: "Post title."],
      date: [
        type: {:custom, Types, :validate_date, []},
        doc: "ISO 8601 date; defaults to the date in the filename."
      ],
      slug: [
        type: :string,
        doc: "URL slug; defaults to the filename after the date."
      ],
      tags: [
        type: {:list, :string},
        default: [],
        doc: "Tags from the shared site taxonomy (also used by the portfolio)."
      ],
      draft: [type: :boolean, default: false, doc: "Drafts are skipped unless `--drafts`."],
      description: [type: :string, doc: "Meta description for SEO and feeds."]
    ]
  end

  @impl Cherry.Collections.Collection
  @spec parse_source(String.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def parse_source(rel_path, meta) do
    case Regex.run(@filename, Path.basename(rel_path)) do
      [_, date_string, slug] ->
        {:ok, date} = Date.from_iso8601(date_string)
        {:ok, Map.merge(%{"date" => date, "slug" => slug}, meta)}

      nil ->
        {:error, "post filename must be YYYY-MM-DD-slug.md"}
    end
  end

  @impl Cherry.Collections.Collection
  @spec route(Document.t()) :: String.t()
  def route(%Document{meta: %{slug: slug}}), do: Path.join(slug, "index.html")
end
