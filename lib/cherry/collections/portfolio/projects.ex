defmodule Cherry.Collections.Portfolio.Projects do
  @moduledoc """
  Projects: `content/portfolio/projects/*.md`.

  Side projects, products, notable work — anything with links and a
  story. `status` says whether it still breathes.
  """

  @behaviour Cherry.Collections.Collection

  alias Cherry.Collections.{Portfolio, Types}
  alias Cherry.Content.Document

  @impl Cherry.Collections.Collection
  @spec dir() :: String.t()
  def dir, do: "content/portfolio/projects"

  @impl Cherry.Collections.Collection
  @spec schema() :: keyword()
  def schema do
    [
      title: [type: :string, required: true, doc: "Project name."],
      status: [
        type: {:in, ["active", "paused", "archived"]},
        default: "active",
        doc: "active | paused | archived."
      ],
      start: Portfolio.date_field("Start date."),
      end: Portfolio.date_field("End date; omit while the project is active."),
      links: [
        type: {:custom, Types, :validate_links, []},
        default: [],
        doc: "Links as `- {label: Source, url: https://…}`."
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
