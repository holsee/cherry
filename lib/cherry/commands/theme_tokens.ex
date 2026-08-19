defmodule Cherry.Commands.ThemeTokens do
  @doc_text """
  Shows the active theme's styling API: every token the theme declares,
  its default, what it does, and any site override from `tokens:` in
  `cherry.exs` — the merged view a restyle works against.

  ## Usage

      mix cherry.theme.tokens [--source DIR] [--json]

  Overrides are written with `cherry config tokens.NAME VALUE`, e.g.

      cherry config tokens.--color-accent "#7c3aed"

  A value applies to both the light and dark renditions unless written
  as `light-dark(a, b)`.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Theme

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())

    with {:ok, site} <- load_site(source),
         {:ok, theme} <- load_theme(site) do
      overrides = Map.new(site.tokens)

      tokens =
        Enum.map(theme.tokens, fn {token, spec} ->
          name = Atom.to_string(token)
          default = Keyword.get(spec, :default)
          override = Map.get(overrides, name)

          %{
            name: name,
            default: default,
            doc: Keyword.get(spec, :doc),
            override: override,
            effective: override || default
          }
        end)

      {:ok, %{theme: theme.name, tokens: tokens, overridden: map_size(overrides)}}
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{theme: theme, tokens: tokens}) do
    width = tokens |> Enum.map(&String.length(&1.name)) |> Enum.max(fn -> 0 end)

    lines =
      Enum.map(tokens, fn token ->
        marker = if token.override, do: " (override; default #{token.default})", else: ""

        "  #{String.pad_trailing(token.name, width)}  #{token.effective}#{marker}" <>
          "\n  #{String.pad_trailing("", width)}  #{token.doc}"
      end)

    Enum.join(["tokens of theme #{theme}:"] ++ lines, "\n")
  end

  defp load_site(source) do
    case Cherry.Site.load(source) do
      {:ok, site} -> {:ok, site}
      {:error, message} -> {:error, %Error{code: :no_site, message: message}}
    end
  end

  defp load_theme(site) do
    case Theme.load_active(site) do
      {:ok, theme} -> {:ok, theme}
      {:error, message} -> {:error, %Error{code: :theme_invalid, message: message}}
    end
  end
end
