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
  @icon_keys for {key, aliases} <- [
                   elixir: ~w(ex exs elixir),
                   phoenix: ~w(heex eex leex),
                   shell: ~w(sh bash zsh shell console),
                   javascript: ~w(js javascript mjs cjs jsx),
                   typescript: ~w(ts typescript tsx),
                   json: ~w(json jsonc),
                   yaml: ~w(yaml yml),
                   markdown: ~w(md markdown),
                   prompt: ~w(prompt),
                   css: ~w(css),
                   html: ~w(html htm xml svg),
                   rust: ~w(rust rs),
                   erlang: ~w(erlang erl),
                   python: ~w(python py)
                 ],
                 alias_name <- aliases,
                 into: %{},
                 do: {alias_name, Atom.to_string(key)}

  @spec icon_key(String.t() | nil) :: String.t()
  defp icon_key(nil), do: "file"
  defp icon_key(lang), do: Map.get(@icon_keys, String.downcase(lang), "file")

  defp escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end
