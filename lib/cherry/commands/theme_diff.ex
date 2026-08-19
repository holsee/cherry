defmodule Cherry.Commands.ThemeDiff do
  @doc_text """
  Reports drift between the site's theme overlays and the installed theme.

  ## Usage

      mix cherry.theme.diff [TEMPLATE] [--source DIR] [--apply] [--json]

  Statuses: `current` (upstream unchanged), `auto_updatable` (upstream
  moved, your copy untouched — `--apply` re-ejects it with fresh
  provenance), `conflict` (both moved; resolve by hand or re-eject with
  `theme.eject --force`), `untracked` (no provenance header),
  `rewritten` (a `.heex` rewrite — owned outright), `shadowed` (an
  `.eex` copy a `.heex` rewrite outranks). This is the managed-drift
  answer to silently frozen theme copies.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Theme
  alias Cherry.Theme.Drift

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, apply: :boolean]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: args, opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    apply? = Keyword.get(opts, :apply, false)

    with {:ok, site} <- load_site(source),
         {:ok, theme} <- load_theme(site),
         {:ok, entries} <- select(Drift.entries(site, theme), args) do
      applied = if apply?, do: apply_updates(entries, theme), else: []

      {:ok,
       %{
         theme: theme.name,
         version: theme.version,
         entries:
           Enum.map(entries, fn entry ->
             %{
               template: Atom.to_string(entry.template),
               path: entry.overlay,
               status: refreshed_status(entry, applied)
             }
           end),
         applied: applied
       }}
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{entries: [], theme: theme}) do
    "no overlays for theme #{theme} — nothing can drift"
  end

  def human(data) do
    lines =
      Enum.map(data.entries, fn entry ->
        "  #{String.pad_trailing(entry.template, 20)} #{entry.status}#{hint(entry.status)}"
      end)

    applied =
      case data.applied do
        [] -> []
        names -> ["applied: #{Enum.join(names, ", ")}"]
      end

    Enum.join(["#{data.theme} #{data.version} overlays:" | lines] ++ applied, "\n")
  end

  defp hint("auto_updatable"), do: " — run with --apply to re-eject"
  defp hint("conflict"), do: " — both changed; resolve, then theme.eject --force"
  defp hint("untracked"), do: " — no provenance; re-eject to enable managed upgrades"
  defp hint("shadowed"), do: " — the .heex rewrite renders; this file is inert"
  defp hint(_status), do: ""

  defp select(entries, []), do: {:ok, entries}

  defp select(entries, [name | _rest]) do
    case Enum.filter(entries, &(Atom.to_string(&1.template) == name)) do
      [] ->
        {:error, %Error{code: :no_overlay, message: "no overlay for template #{name}", exit: 2}}

      found ->
        {:ok, found}
    end
  end

  defp apply_updates(entries, theme) do
    for entry <- entries, entry.status == :auto_updatable, Drift.update(entry, theme) == :ok do
      Atom.to_string(entry.template)
    end
  end

  defp refreshed_status(entry, applied) do
    name = Atom.to_string(entry.template)
    if name in applied, do: "current", else: Atom.to_string(entry.status)
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
