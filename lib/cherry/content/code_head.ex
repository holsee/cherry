defmodule Cherry.Content.CodeHead do
  @moduledoc """
  The header bar above fenced code blocks: the language in small text, an
  optional file path, and a file-type icon.

  The fence info string carries both, Docusaurus-style:

      ```elixir title="lib/cherry/cli.ex"

  Language and title are each optional; a fence with neither renders the
  bare `<pre>` it always did. The header is a `<figcaption class="code-head">`
  inside a `<figure class="code-block">` wrapper, and the icon is an empty
  span the theme paints with a CSS mask: `code-icon code-icon--KEY`. The
  official themes ship the glyph set (sourced from
  [devicon](https://github.com/devicons/devicon), MIT — the same icons
  editor file trees use); a language without a glyph falls back to the
  generic file icon that `.code-icon` carries by default.
  """

  @doc """
  Parses a fence info string into `{language, title}`, either `nil` when
  absent. The language is the first token as the author wrote it; the
  title is the value of a `title="…"` pair anywhere in the rest.
  """
  @spec parse(String.t() | nil) :: {String.t() | nil, String.t() | nil}
  def parse(info) do
    info = info |> to_string() |> String.trim()

    lang =
      case String.split(info, ~r/\s+/, trim: true) do
        [first | _rest] -> if String.contains?(first, "="), do: nil, else: first
        [] -> nil
      end

    title =
      case Regex.run(~r/title="([^"]*)"/, info) do
        [_full, ""] -> nil
        [_full, title] -> title
        nil -> nil
      end

    {lang, title}
  end

  @doc """
  Wraps a rendered `<pre>` block in the figure + header. Call only when
  `parse/1` produced a language or a title.
  """
  @spec wrap(String.t(), String.t() | nil, String.t() | nil) :: String.t()
  def wrap(pre_html, lang, title) do
    label = if lang, do: ~s(<span class="code-lang">#{escape(lang)}</span>), else: ""
    path = if title, do: ~s(<span class="code-title">#{escape(title)}</span>), else: ""

    icon = ~s(<span class="code-icon code-icon--#{icon_key(lang)}" aria-hidden="true"></span>)

    ~s(<figure class="code-block"><figcaption class="code-head">#{icon}#{label}#{path}</figcaption>#{pre_html}</figure>)
  end

  # The icon key normalises fence-language aliases onto the glyph set the
  # official themes ship. Unknown languages key "file", the default glyph
  # every `.code-icon` carries, so third-party themes degrade gracefully.
  @spec icon_key(String.t() | nil) :: String.t()
  defp icon_key(nil), do: "file"

  defp icon_key(lang) do
    case String.downcase(lang) do
      l when l in ~w(ex exs elixir) -> "elixir"
      l when l in ~w(heex eex leex) -> "phoenix"
      l when l in ~w(sh bash zsh shell console) -> "shell"
      l when l in ~w(js javascript mjs cjs jsx) -> "javascript"
      l when l in ~w(ts typescript tsx) -> "typescript"
      l when l in ~w(json jsonc) -> "json"
      l when l in ~w(yaml yml) -> "yaml"
      l when l in ~w(md markdown) -> "markdown"
      l when l in ~w(css) -> "css"
      l when l in ~w(html htm xml svg) -> "html"
      l when l in ~w(rust rs) -> "rust"
      l when l in ~w(erlang erl) -> "erlang"
      l when l in ~w(python py) -> "python"
      _other -> "file"
    end
  end

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end
