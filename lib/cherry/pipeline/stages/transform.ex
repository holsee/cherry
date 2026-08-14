defmodule Cherry.Pipeline.Stages.Transform do
  @moduledoc """
  Renders markdown bodies to HTML with MDEx (GFM extensions on).

  Raw HTML inside markdown is allowed — this is the author's own site, and
  Octopress-era posts lean on embedded HTML. Non-markdown documents pass
  their body through unchanged.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.Document

  @mdex_options [
    extension: [
      table: true,
      strikethrough: true,
      autolink: true,
      tasklist: true,
      footnotes: true
    ],
    render: [unsafe: true]
  ]

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{} = build) do
    {:ok, %Build{build | documents: Enum.map(build.documents, &transform/1)}}
  end

  defp transform(%Document{raw?: true} = doc), do: doc

  defp transform(%Document{} = doc) do
    if Path.extname(doc.source) == ".md" do
      %Document{doc | html: MDEx.to_html!(doc.body, @mdex_options)}
    else
      %Document{doc | html: doc.body}
    end
  end
end
