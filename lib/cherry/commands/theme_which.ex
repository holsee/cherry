defmodule Cherry.Commands.ThemeWhich do
  @doc_text """
  Prints the full resolution chain for one template: site overlay →
  theme → framework. Three levels, never more; the arrow marks the file
  that will render.

  ## Usage

      mix cherry.theme.which TEMPLATE [--source DIR] [--json]
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Theme
  alias Cherry.Theme.Resolver

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [name], opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())

    with {:ok, site} <- load_site(source),
         {:ok, theme} <- load_theme(site) do
      template = String.to_existing_atom(name)
      chain = Resolver.chain(site, theme, template)

      {:ok,
       %{
         template: name,
         winner: winner_level(chain),
         chain:
           Enum.map(chain, fn {level, path, exists?} ->
             %{level: Atom.to_string(level), path: path, exists: exists?}
           end)
       }}
    end
  rescue
    ArgumentError ->
      {:error,
       %Error{
         code: :unknown_template,
         message:
           "unknown template — contract templates: " <>
             Enum.map_join(Theme.required_templates(), ", ", &to_string/1),
         exit: 2
       }}
  end

  def run(%Context{}) do
    {:error, %Error{code: :usage, message: "usage: cherry theme.which TEMPLATE", exit: 2}}
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{template: template, winner: winner, chain: chain}) do
    lines =
      Enum.map(chain, fn entry ->
        marker = if (winner && entry.level == winner) and entry.exists, do: " ← renders", else: ""
        presence = if entry.exists, do: "", else: " (missing)"
        "  #{String.pad_trailing(entry.level, 13)} #{entry.path}#{presence}#{marker}"
      end)

    Enum.join(["#{template}:" | lines], "\n")
  end

  defp winner_level(chain) do
    case Enum.find(chain, fn {_level, _path, exists?} -> exists? end) do
      {level, _path, true} -> Atom.to_string(level)
      nil -> nil
    end
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
