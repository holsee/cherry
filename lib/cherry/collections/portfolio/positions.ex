defmodule Cherry.Collections.Portfolio.Positions do
  @moduledoc """
  Employment positions: `content/portfolio/positions/*.md`.

  The markdown body is the long-form story; `highlights` are the
  timeline bullets. An open `end:` means the position is current.
  """

  @behaviour Cherry.Collections.Collection

  alias Cherry.Collections.Portfolio
  alias Cherry.Content.Document

  @impl Cherry.Collections.Collection
  @spec dir() :: String.t()
  def dir, do: "content/portfolio/positions"

  @impl Cherry.Collections.Collection
  @spec schema() :: keyword()
  def schema do
    [
      title: [type: :string, required: true, doc: "Role title, e.g. \"Staff Engineer\"."],
      org: [type: :string, required: true, doc: "Organisation name."],
      start: Portfolio.date_field("Start date.", required: true),
      end: Portfolio.date_field("End date; omit while the position is current."),
      location: [type: :string, doc: "City / remote — free text."]
    ] ++ Portfolio.common_fields()
  end

  @impl Cherry.Collections.Collection
  @spec parse_source(String.t(), map()) :: {:ok, map()}
  defdelegate parse_source(rel_path, meta), to: Portfolio

  @impl Cherry.Collections.Collection
  @spec route(Document.t()) :: nil
  def route(%Document{}), do: nil
end
