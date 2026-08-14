defmodule Cherry.Collections.Portfolio.Education do
  @moduledoc """
  Education: `content/portfolio/education/*.md`.

  Degrees, certifications, and formal courses; joins the portfolio
  built-ins so the CV's education section is data like everything else.
  """

  @behaviour Cherry.Collections.Collection

  alias Cherry.Collections.Portfolio
  alias Cherry.Content.Document

  @impl Cherry.Collections.Collection
  @spec dir() :: String.t()
  def dir, do: "content/portfolio/education"

  @impl Cherry.Collections.Collection
  @spec schema() :: keyword()
  def schema do
    [
      title: [type: :string, required: true, doc: "Qualification, e.g. \"BSc Computer Science\"."],
      institution: [type: :string, required: true, doc: "School or issuing body."],
      start: Portfolio.date_field("Start date."),
      end: Portfolio.date_field("Completion date; omit while ongoing.")
    ] ++ Portfolio.common_fields()
  end

  @impl Cherry.Collections.Collection
  @spec parse_source(String.t(), map()) :: {:ok, map()}
  defdelegate parse_source(rel_path, meta), to: Portfolio

  @impl Cherry.Collections.Collection
  @spec route(Document.t()) :: nil
  def route(%Document{}), do: nil
end
