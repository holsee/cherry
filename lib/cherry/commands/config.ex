defmodule Cherry.Commands.Config do
  @doc_text """
  Reads and writes `cherry.exs`, so a site can be configured without an
  editor.

  ## Usage

      mix cherry.config [--source DIR] [--json]
      mix cherry.config KEY [--source DIR] [--json]
      mix cherry.config KEY VALUE [--source DIR] [--json]

  With no arguments it prints the site's resolved configuration. With a
  key it prints one value. With a key and a value it writes that value
  to `cherry.exs` and reloads the site to prove the result is valid —
  an invalid write is rolled back and reported, so the file is never
  left broken.

  Writable keys are the scalar ones: #{inspect(~w(title url description author theme search base_path social_image))}.
  Structured settings like `nav:` are refused rather than rewritten,
  because rewriting them would lose the formatting and comments around
  them; edit those in the file.

  Only the value being changed is rewritten — the rest of the file,
  including comments and layout, is left byte-for-byte alone.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Site

  @writable ~w(title url description author theme search base_path social_image)
  @readable @writable ++ ~w(nav)

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [], opts: opts}) do
    with {:ok, site} <- load(source(opts)) do
      {:ok, %{config: Map.new(@readable, &{&1, readable_value(site, &1)})}}
    end
  end

  def run(%Context{args: [key], opts: opts}) do
    with :ok <- known?(key, @readable),
         {:ok, site} <- load(source(opts)) do
      {:ok, %{key: key, value: readable_value(site, key)}}
    end
  end

  def run(%Context{args: [key, value], opts: opts}) do
    source = source(opts)
    path = Path.join(source, "cherry.exs")

    with :ok <- known?(key, @writable),
         {:ok, site} <- load(source),
         {:ok, original} <- read(path),
         :ok <- File.write(path, put(original, key, value)),
         :ok <- revalidate(source, path, original) do
      {:ok, %{key: key, value: value, previous: readable_value(site, key), path: "cherry.exs"}}
    end
  end

  def run(%Context{}) do
    {:error, %Error{code: :usage, message: "usage: cherry config [KEY [VALUE]]", exit: 2}}
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{config: config}) do
    config
    |> Enum.sort()
    |> Enum.map_join("\n", fn {key, value} -> "#{String.pad_trailing(key, 14)} #{show(value)}" end)
  end

  def human(%{key: key, value: value, previous: previous}) do
    "#{key}: #{show(previous)} → #{show(value)} (written to cherry.exs)"
  end

  def human(%{key: key, value: value}), do: "#{key}: #{show(value)}"

  defp show(nil), do: "(unset)"

  defp show(value) when is_list(value),
    do: "#{length(value)} entr#{if length(value) == 1, do: "y", else: "ies"}"

  defp show(value), do: to_string(value)

  defp source(opts), do: Keyword.get(opts, :source, File.cwd!())

  defp readable_value(site, "nav"), do: site.nav
  defp readable_value(site, key), do: Map.get(site, String.to_existing_atom(key))

  defp known?(key, allowed) do
    if key in allowed do
      :ok
    else
      {:error,
       %Error{
         code: :unknown_key,
         message: "unknown or unwritable key: #{key} — available: #{Enum.join(allowed, ", ")}",
         exit: 2
       }}
    end
  end

  defp load(source) do
    case Site.load(source) do
      {:ok, site} -> {:ok, site}
      {:error, message} -> {:error, %Error{code: :no_site, message: message}}
    end
  end

  defp read(path) do
    case File.read(path) do
      {:ok, content} ->
        {:ok, content}

      {:error, reason} ->
        {:error, %Error{code: :no_config, message: "#{path}: #{:file.format_error(reason)}"}}
    end
  end

  # Replaces one value in place, or inserts the key before the closing
  # bracket. Everything else in the file is untouched — which is why this
  # matches on the keyword boundary rather than the start of a line: a
  # config written on one line is still a config.
  defp put(content, key, value) do
    literal = inspect(value)
    pattern = key_pattern(key)

    if Regex.match?(pattern, content) do
      Regex.replace(pattern, content, "#{key}: #{literal}", global: false)
    else
      insert(content, key, literal)
    end
  end

  # A key sits after `[`, after a comma, or after whitespace, and its
  # value runs to the next comma or the closing bracket — unless it is a
  # quoted string, which may contain either.
  defp key_pattern(key) do
    ~r/(?<=[\[,\s])#{Regex.escape(key)}:\s*(?:"(?:[^"\\]|\\.)*"|[^,\]\n]+)/
  end

  defp insert(content, key, literal) do
    trimmed = String.trim_trailing(content)
    {body, closing} = String.split_at(trimmed, -1)

    if closing == "]" do
      String.trim_trailing(body) |> comma() |> Kernel.<>("\n  #{key}: #{literal}\n]\n")
    else
      trimmed <> "\n"
    end
  end

  defp comma(body), do: if(String.ends_with?(body, ","), do: body, else: body <> ",")

  # The proof the write is good: reload the site. A value the schema
  # rejects puts the original file back rather than leaving a site that
  # no longer loads.
  defp revalidate(source, path, original) do
    case Site.load(source) do
      {:ok, _site} ->
        :ok

      {:error, message} ->
        File.write!(path, original)

        {:error,
         %Error{code: :invalid_value, message: "#{message} — cherry.exs left unchanged", exit: 2}}
    end
  end
end
