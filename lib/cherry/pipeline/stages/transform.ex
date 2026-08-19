defmodule Cherry.Pipeline.Stages.Transform do
  @moduledoc """
  Renders markdown bodies to HTML with MDEx (GFM extensions on).

  Raw HTML inside markdown is allowed — this is the author's own site, and
  Octopress-era posts lean on embedded HTML. Non-markdown documents pass
  their body through unchanged.

  Headings carry ids plus a trailing `a.anchor` deep link
  (`header_id_prefix`), and GitHub-style alerts (`> [!NOTE]` …) render as
  `div.markdown-alert-*` blocks — both styled by the official themes.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Content.{Components, Document}

  @mdex_options [
    extension: [
      table: true,
      strikethrough: true,
      autolink: true,
      tasklist: true,
      footnotes: true,
      # Not the deprecated `header_ids` shim — that one IO.warns.
      header_id_prefix: "",
      alerts: true
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
    base_path = build.site.base_path
    {:ok, %Build{build | documents: Enum.map(build.documents, &transform(&1, base_path))}}
  end

  defp transform(%Document{raw?: true} = doc, _base_path), do: doc

  defp transform(%Document{} = doc, base_path) do
    if Path.extname(doc.source) == ".md" do
      # Content components (::figure, ::video, :::note …) expand to HTML
      # before markdown; MDEx then renders the markdown between them.
      html =
        doc.body
        |> Components.render(base_path)
        |> MDEx.to_html!(@mdex_options)
        |> wrap_tables()

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
