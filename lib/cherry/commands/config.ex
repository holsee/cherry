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
  Structured settings like `nav:` and `analytics:` are read but refused
  for writing rather than rewritten,
  because rewriting them would lose the formatting and comments around
  them; edit those in the file.

  Theme token overrides are the exception, addressed with a dotted key:

      cherry config tokens                          # every override
      cherry config tokens.--color-accent           # one override
      cherry config tokens.--color-accent "#7c3aed" # write one

  A written token must exist in the active theme's manifest
  (`cherry theme.tokens` lists them), so a typo is an error here rather
  than a silently ignored line in `cherry.exs`.

  Only the value being changed is rewritten — the rest of the file,
  including comments and layout, is left byte-for-byte alone.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.Analytics
  alias Cherry.CLI.{Context, Error}
  alias Cherry.Site

  @writable ~w(title url description author theme search base_path social_image)
  @readable @writable ++ ~w(analytics nav tokens)

  @impl Cherry.CLI.Command
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

  def run(%Context{args: ["tokens." <> token], opts: opts}) do
    with {:ok, site} <- load(source(opts)) do
      {:ok, %{key: "tokens.#{token}", value: token_value(site, token)}}
    end
  end

  def run(%Context{args: [key], opts: opts}) do
    with :ok <- known?(key, @readable),
         {:ok, site} <- load(source(opts)) do
      {:ok, %{key: key, value: readable_value(site, key)}}
    end
  end

  def run(%Context{args: ["tokens." <> token, value], opts: opts}) do
    source = source(opts)
    path = Path.join(source, "cherry.exs")

    with {:ok, site} <- load(source),
         :ok <- token_known?(site, token),
         {:ok, original} <- read(path),
         :ok <- File.write(path, put_token(original, token, value)),
         :ok <- revalidate(source, path, original) do
      {:ok,
       %{
         key: "tokens.#{token}",
         value: value,
         previous: token_value(site, token),
         path: "cherry.exs"
       }}
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

  defp show(value) when is_map(value) and map_size(value) == 0, do: "(none)"

  defp show(value) when is_map(value),
    do: Enum.map_join(Enum.sort(value), ", ", fn {name, val} -> "#{name}=#{val}" end)

  defp show(value), do: to_string(value)

  defp source(opts), do: Keyword.get(opts, :source, File.cwd!())

  defp readable_value(site, "analytics"), do: analytics_value(site.analytics)
  defp readable_value(site, "nav"), do: site.nav
  defp readable_value(site, "tokens"), do: Map.new(site.tokens)
  defp readable_value(site, key), do: Map.get(site, String.to_existing_atom(key))

  # A plain map, not the struct: this is what `--json` hands an agent, and
  # the consent class is the part worth reading — it decides whether a
  # consent gate ships with the beacon.
  defp analytics_value(nil), do: nil

  defp analytics_value(%Analytics{} = analytics) do
    %{
      provider: Atom.to_string(analytics.provider),
      id: analytics.id,
      host: analytics.host,
      consent_required: Analytics.consent_required?(analytics)
    }
  end

  defp token_value(site, token) do
    Enum.find_value(site.tokens, fn {name, value} -> name == token && value end)
  end

  # A token write is only as good as the name: validate against the
  # active theme's manifest up front, so `cherry.exs` never gains a line
  # the build would then refuse.
  defp token_known?(site, token) do
    case Cherry.Theme.load_active(site) do
      {:ok, theme} ->
        case Cherry.Theme.validate_overrides(theme, [{token, "pending"}]) do
          :ok -> :ok
          {:error, message} -> {:error, %Error{code: :unknown_key, message: message, exit: 2}}
        end

      {:error, message} ->
        {:error, %Error{code: :theme_invalid, message: message}}
    end
  end

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

  # Token writes are the one structured exception: entries are quoted-atom
  # keys (`"--color-accent": "#7c3aed"`), distinctive enough to address
  # individually without reformatting the list around them.
  defp put_token(content, token, value) do
    literal = inspect(value)
    entry = ~s("#{token}": #{literal})
    existing = ~r/"#{Regex.escape(token)}":\s*"(?:[^"\\]|\\.)*"/

    cond do
      Regex.match?(existing, content) ->
        Regex.replace(existing, content, entry, global: false)

      Regex.match?(~r/tokens:\s*\[\s*\]/, content) ->
        Regex.replace(~r/tokens:\s*\[\s*\]/, content, "tokens: [#{entry}]", global: false)

      Regex.match?(~r/tokens:\s*\[/, content) ->
        Regex.replace(~r/tokens:\s*\[/, content, "tokens: [#{entry}, ", global: false)

      true ->
        insert(content, "tokens", "[#{entry}]")
    end
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
