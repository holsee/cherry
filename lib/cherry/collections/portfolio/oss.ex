defmodule Cherry.Collections.Portfolio.Oss do
  @moduledoc """
  Open source: `content/portfolio/oss/*.md`.

  Repositories where the author holds a named role — author,
  maintainer, or contributor.
  """

  @behaviour Cherry.Collections.Collection

  alias Cherry.Collections.Portfolio
  alias Cherry.Content.Document

  @impl Cherry.Collections.Collection
  @spec dir() :: String.t()
  def dir, do: "content/portfolio/oss"

  @impl Cherry.Collections.Collection
  @spec schema() :: keyword()
  def schema do
    [
      title: [type: :string, required: true, doc: "Project name."],
      repo: [type: :string, required: true, doc: "Repository URL."],
      role: [
        type: {:in, ["author", "maintainer", "contributor"]},
        required: true,
        doc: "author | maintainer | contributor."
      ]
    ] ++ Portfolio.common_fields()
  end

  @impl Cherry.Collections.Collection
  @spec parse_source(String.t(), map()) :: {:ok, map()}
  defdelegate parse_source(rel_path, meta), to: Portfolio

  @impl Cherry.Collections.Collection
  @spec route(Document.t()) :: nil
  def route(%Document{}), do: nil
end
