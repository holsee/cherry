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
    render: [unsafe: true],
    # html_linked emits class-based tokens with no baked colors; the theme's
    # CSS colors them from its own custom properties, so light and dark
    # renditions swap code and prose as one world.
    syntax_highlight: [formatter: :html_linked]
  ]

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{} = build) do
    {:ok, %Build{build | documents: Enum.map(build.documents, &transform/1)}}
  end

  defp transform(%Document{raw?: true} = doc), do: doc

  defp transform(%Document{} = doc) do
    if Path.extname(doc.source) == ".md" do
      html = doc.body |> MDEx.to_html!(@mdex_options) |> wrap_tables()
      %Document{doc | html: html}
    else
      %Document{doc | html: doc.body}
    end
  end

  # Tables scroll inside their own box on narrow screens without losing
  # table semantics (a bare `display: block` table would). Markdown cannot
  # nest tables, so plain string wrapping is safe.
  defp wrap_tables(html) do
    html
    |> String.replace("<table>", ~s(<div class="table-scroll"><table>))
    |> String.replace("</table>", "</table></div>")
  end
end
