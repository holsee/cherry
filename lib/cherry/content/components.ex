defmodule Cherry.Content.Components do
  @moduledoc """
  Content components: a small, framework-level set of directives that
  work in any theme, so content never accumulates theme-specific markup
  (DESIGN.md — that is precisely why Jekyll theme swaps break).

  The syntax is the remark-directive convention modern authors already
  know from Docusaurus and VitePress:

      ::figure{src="images/pipeline.svg" alt="The pipeline" caption="Nine stages."}

      ::video{youtube="dQw4w9WgXcQ" title="The demo"}

      :::tip{title="Heads up"}
      Any **markdown** works in here.
      :::

  Leaf directives (`::name{…}`) sit on their own line; containers
  (`:::name{…}` … `:::`) wrap markdown. The five containers are the
  GitHub alert types — `note`, `tip`, `important`, `warning`, `caution` —
  rendered onto the same `.markdown-alert-*` classes both official
  themes already style, with an optional custom `title`.

  Rendering happens before markdown (the emitted HTML is block-level and
  blank-line separated, so the markdown between container fences renders
  normally). Bad usage never breaks a build: an unknown name or a
  missing required attribute leaves the line verbatim in the output and
  becomes a `component` diagnostic in `cherry check`, which names the
  file, the directive, and what is wrong.
  """

  alias Cherry.Check.Diagnostic

  @containers ~w(note tip important warning caution)

  @doc """
  Expands every well-formed directive in a markdown body to HTML.

  Root-absolute `src`/`poster` paths pick up the site's `base_path`
  (`/images/a.svg` → `/repo/images/a.svg` on project pages) — one thing
  components can do for authors that raw markdown cannot. Malformed or
  unknown directives are left byte-for-byte alone — `diagnose/2` is
  where they get named.
  """
  @spec render(String.t(), String.t()) :: String.t()
  def render(body, base_path \\ "/") do
    body
    |> String.split("\n")
    |> walk(fn line, open -> expand_line(line, open, base_path) end)
    |> Enum.join("\n")
  end

  # Walks lines with the two pieces of state expansion needs: whether we
  # are inside a fenced code block (directives there are being *shown*,
  # never expanded — the guide quotes its own syntax), and how many
  # containers are open (a stray ::: with nothing open stays verbatim).
  defp walk(lines, fun) do
    {output, _state} =
      Enum.map_reduce(lines, {false, 0}, fn line, {in_fence?, open} ->
        cond do
          fence_delimiter?(line) ->
            {line, {not in_fence?, open}}

          in_fence? ->
            {line, {in_fence?, open}}

          true ->
            {out, open} = fun.(line, open)
            {out, {in_fence?, open}}
        end
      end)

    output
  end

  defp fence_delimiter?(line) do
    String.trim_leading(line) |> String.starts_with?(["```", "~~~"])
  end

  @doc """
  Diagnostics for every directive-shaped line the renderer refused:
  unknown component names, missing required attributes, attributes the
  component does not take, and an unclosed container fence.
  """
  @spec diagnose(String.t(), Path.t()) :: [Diagnostic.t()]
  def diagnose(body, file) do
    lines = prose_lines(body)

    problems =
      for {line, n} <- lines,
          message = problem(line),
          do: %Diagnostic{
            file: file,
            line: n,
            rule: "component",
            message: message,
            severity: :error
          }

    problems ++ unclosed_fence(lines, file)
  end

  # {line, number} pairs outside fenced code blocks — the only place a
  # directive means anything.
  defp prose_lines(body) do
    body
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.map_reduce(false, fn {line, n}, in_fence? ->
      cond do
        fence_delimiter?(line) -> {nil, not in_fence?}
        in_fence? -> {nil, in_fence?}
        true -> {{line, n}, in_fence?}
      end
    end)
    |> elem(0)
    |> Enum.reject(&is_nil/1)
  end

  # --- expansion --------------------------------------------------------

  defp expand_line(line, open, base_path) do
    case parse(line) do
      {:ok, :close, _attrs} when open > 0 ->
        {"\n</div>", open - 1}

      {:ok, :close, _attrs} ->
        {line, open}

      {:ok, {:container, _name} = directive, attrs} ->
        case emit(directive, attrs) do
          nil -> {line, open}
          html -> {html, open + 1}
        end

      {:ok, directive, attrs} ->
        {emit(directive, rebase(attrs, base_path)) || line, open}

      :not_a_directive ->
        {line, open}
    end
  end

  # Root-absolute asset paths respect base_path, like every path the
  # framework emits. Relative and external values pass verbatim.
  defp rebase(attrs, base_path) do
    Map.new(attrs, fn {key, value} ->
      if key in ~w(src poster) and String.starts_with?(value, "/") and
           not String.starts_with?(value, "//") do
        {key, base_path <> String.trim_leading(value, "/")}
      else
        {key, value}
      end
    end)
  end

  # `:::` alone closes a container; `:::name{…}` opens one; `::name{…}`
  # is a leaf. Anything else passes through.
  defp parse(line) do
    trimmed = String.trim(line)

    cond do
      trimmed == ":::" ->
        {:ok, :close, %{}}

      match = Regex.run(~r/^:::([a-z][a-z-]*)(\{.*\})?\s*$/, trimmed) ->
        [_all, name | rest] = match
        {:ok, {:container, name}, parse_attrs(rest)}

      match = Regex.run(~r/^::([a-z][a-z-]*)(\{.*\})?\s*$/, trimmed) ->
        [_all, name | rest] = match
        {:ok, {:leaf, name}, parse_attrs(rest)}

      true ->
        :not_a_directive
    end
  end

  defp parse_attrs([]), do: %{}
  defp parse_attrs([""]), do: %{}

  defp parse_attrs([braced]) do
    ~r/([a-z][a-z-]*)="([^"]*)"/
    |> Regex.scan(braced)
    |> Map.new(fn [_all, key, value] -> {key, value} end)
  end

  defp emit(:close, _attrs), do: "</div>"

  defp emit({:container, name}, attrs) when name in @containers do
    if map_size(Map.drop(attrs, ["title"])) == 0 do
      title = attrs["title"] || String.capitalize(name)

      ~s(<div class="markdown-alert markdown-alert-#{name}">\n) <>
        ~s(<p class="markdown-alert-title">#{escape(title)}</p>\n)
    end
  end

  defp emit({:leaf, "figure"}, %{"src" => src, "alt" => alt} = attrs)
       when src != "" and alt != "" do
    if map_size(Map.drop(attrs, ~w(src alt caption))) == 0 do
      caption =
        case attrs["caption"] do
          nil -> ""
          text -> "\n<figcaption>#{escape(text)}</figcaption>"
        end

      ~s(<figure>\n<img src="#{escape(src)}" alt="#{escape(alt)}">#{caption}\n</figure>)
    end
  end

  # YouTube: a plain link at rest — zero third-party requests until the
  # reader acts. The video-embed island upgrades the click to an in-place
  # youtube-nocookie iframe; without JS the link just goes to YouTube.
  defp emit({:leaf, "video"}, %{"youtube" => id, "title" => title} = attrs)
       when id != "" and title != "" do
    if map_size(Map.drop(attrs, ~w(youtube title))) == 0 do
      ~s(<a class="video-embed" href="https://www.youtube.com/watch?v=#{escape(id)}" data-video-embed="#{escape(id)}">\n) <>
        ~s(<span class="video-embed-play" aria-hidden="true"></span>\n) <>
        ~s(<span class="video-embed-title">#{escape(title)}</span>\n</a>)
    end
  end

  defp emit({:leaf, "video"}, %{"src" => src} = attrs) when src != "" do
    if map_size(Map.drop(attrs, ~w(src title poster))) == 0 do
      poster =
        case attrs["poster"] do
          nil -> ""
          path -> ~s( poster="#{escape(path)}")
        end

      title =
        case attrs["title"] do
          nil -> ""
          text -> ~s( title="#{escape(text)}")
        end

      ~s(<video class="video-local" controls preload="metadata"#{poster}#{title} src="#{escape(src)}"></video>)
    end
  end

  defp emit(_name, _attrs), do: nil

  # --- diagnosis --------------------------------------------------------

  defp problem(line) do
    case parse(line) do
      :not_a_directive -> nil
      {:ok, name, attrs} -> if emit(name, attrs), do: nil, else: describe(name, attrs)
    end
  end

  defp describe({:container, name}, _attrs) when name not in @containers do
    "unknown component :::#{name} — containers are #{Enum.join(@containers, ", ")}"
  end

  defp describe({:container, name}, attrs) do
    unknown_attrs(":::#{name}", attrs, ~w(title))
  end

  defp describe({:leaf, "figure"}, attrs) do
    missing = for key <- ~w(src alt), attrs[key] in [nil, ""], do: key

    if missing == [] do
      unknown_attrs("::figure", attrs, ~w(src alt caption))
    else
      "::figure needs #{Enum.join(missing, " and ")} — alt text is not optional"
    end
  end

  defp describe({:leaf, "video"}, attrs) do
    cond do
      attrs["youtube"] not in [nil, ""] and attrs["title"] in [nil, ""] ->
        "::video{youtube=…} needs a title — it becomes the link text and the accessible name"

      attrs["youtube"] in [nil, ""] and attrs["src"] in [nil, ""] ->
        "::video needs youtube=\"ID\" or src=\"path\""

      attrs["youtube"] not in [nil, ""] ->
        unknown_attrs("::video", attrs, ~w(youtube title))

      true ->
        unknown_attrs("::video", attrs, ~w(src title poster))
    end
  end

  defp describe({:leaf, name}, _attrs) do
    "unknown component ::#{name} — leaves are figure, video"
  end

  defp unknown_attrs(directive, attrs, allowed) do
    case Map.keys(attrs) -- allowed do
      [] -> "#{directive}: malformed attributes"
      extra -> "#{directive} does not take #{Enum.join(extra, ", ")}"
    end
  end

  defp unclosed_fence(lines, file) do
    opens = Enum.count(lines, fn {line, _n} -> Regex.match?(~r/^:::[a-z]/, String.trim(line)) end)
    closes = Enum.count(lines, fn {line, _n} -> String.trim(line) == ":::" end)

    if opens > closes do
      [
        %Diagnostic{
          file: file,
          rule: "component",
          message: "a ::: container is never closed — add a line holding only :::",
          severity: :error
        }
      ]
    else
      []
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
