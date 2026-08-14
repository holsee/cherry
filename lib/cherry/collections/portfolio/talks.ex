defmodule Cherry.Collections.Portfolio.Talks do
  @moduledoc """
  Talks: `content/portfolio/talks/*.md`.

  Conference and meetup appearances, with the recording and slides a
  click away.
  """

  @behaviour Cherry.Collections.Collection

  alias Cherry.Collections.Portfolio
  alias Cherry.Content.Document

  @impl Cherry.Collections.Collection
  @spec dir() :: String.t()
  def dir, do: "content/portfolio/talks"

  @impl Cherry.Collections.Collection
  @spec schema() :: keyword()
  def schema do
    [
      title: [type: :string, required: true, doc: "Talk title."],
      event: [type: :string, required: true, doc: "Conference or meetup name."],
      date: Portfolio.date_field("Date of the talk.", required: true),
      video: [type: :string, doc: "Recording URL."],
      slides: [type: :string, doc: "Slides URL."]
    ] ++ Portfolio.common_fields()
  end

  @impl Cherry.Collections.Collection
  @spec parse_source(String.t(), map()) :: {:ok, map()}
  defdelegate parse_source(rel_path, meta), to: Portfolio

  @impl Cherry.Collections.Collection
  @spec route(Document.t()) :: nil
  def route(%Document{}), do: nil
end
