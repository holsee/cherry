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
  alias Cherry.Content.{CodeHead, Components, Document}

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
        |> MDEx.parse_document!(@mdex_options)
        |> decorate_code_blocks()
        |> MDEx.to_html!(@mdex_options)
        |> wrap_tables()
        |> rebase_links(base_path)

      %Document{doc | html: html}
    else
      %Document{doc | html: doc.body}
    end
  end

  # Fenced blocks with a language or a `title="…"` gain a header bar
  # (Cherry.Content.CodeHead): the block renders alone through the same
  # pipeline options, then re-enters the document as raw HTML wrapped in
  # the figure. Indented blocks and bare fences stay exactly as they were.
  defp decorate_code_blocks(document) do
    MDEx.traverse_and_update(document, fn
      %MDEx.CodeBlock{fenced: true, info: info} = node ->
        case CodeHead.parse(info) do
          {nil, nil} ->
            node

          {lang, title} ->
            pre =
              MDEx.to_html!(
                %MDEx.Document{nodes: [%MDEx.CodeBlock{node | info: lang || ""}]},
                @mdex_options
              )

            %MDEx.HtmlBlock{literal: CodeHead.wrap(String.trim_trailing(pre), lang, title)}
        end

      other ->
        other
    end)
  end

  # Tables scroll inside their own box on narrow screens without losing
  # table semantics (a bare `display: block` table would). Markdown cannot
  # nest tables, so plain string wrapping is safe.
  defp wrap_tables(html) do
    html
    |> String.replace("<table>", ~s(<div class="table-scroll"><table>))
    |> String.replace("</table>", "</table></div>")
  end

  # Root-absolute links and sources written in markdown (`[blog](/blog/)`,
  # `<img src="/images/x.png">`) mean "this site", so under a `base_path`
  # they move with it - the same rule the layout and the components apply.
  # Protocol-relative URLs (`//host/…`) and paths already under the base
  # are left alone.
  @rootlink ~r/\b(href|src)="\/(?!\/)([^"]*)"/

  defp rebase_links(html, "/"), do: html

  defp rebase_links(html, base_path) do
    Regex.replace(@rootlink, html, fn whole, attr, rest ->
      if String.starts_with?("/" <> rest, base_path) do
        whole
      else
        ~s(#{attr}="#{base_path}#{rest}")
      end
    end)
  end
end
