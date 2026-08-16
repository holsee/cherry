defmodule Cherry.Commands.ThemeEject do
  @doc_text """
  Copies a theme template into the site's per-theme overlay with a
  recorded provenance header (theme, version, content hash).

  Never hand-copy a theme file: the header is what lets `theme.diff`
  three-way-merge upgrades later instead of your copy silently freezing.

  ## Usage

      mix cherry.theme.eject TEMPLATE [--source DIR] [--force] [--json]
      mix cherry.theme.eject --all [--source DIR] [--force] [--json]
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Theme
  alias Cherry.Theme.{Provenance, Resolver}

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, all: :boolean, force: :boolean]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: args, opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    force? = Keyword.get(opts, :force, false)

    with {:ok, site} <- load_site(source),
         {:ok, theme} <- load_theme(site),
         {:ok, names} <- targets(args, opts, theme) do
      eject_all(names, site, theme, force?)
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{ejected: ejected}) do
    lines = Enum.map(ejected, &"  #{&1.template} → #{&1.path}")

    Enum.join(
      ["Ejected #{length(ejected)} template(s) with provenance:" | lines] ++
        ["Edit away — `cherry theme.diff` keeps upgrades mergeable."],
      "\n"
    )
  end

  defp targets(args, opts, theme) do
    cond do
      Keyword.get(opts, :all, false) ->
        {:ok, Enum.map(theme.templates, & &1.name)}

      args == [] ->
        {:error,
         %Error{code: :usage, message: "usage: cherry theme.eject TEMPLATE | --all", exit: 2}}

      true ->
        [name | _rest] = args

        case Enum.find(theme.templates, &(Atom.to_string(&1.name) == name)) do
          nil ->
            {:error,
             %Error{
               code: :unknown_template,
               message:
                 "theme #{theme.name} has no template #{inspect(name)} — inventory: " <>
                   Enum.map_join(theme.templates, ", ", &to_string(&1.name)),
               exit: 2
             }}

          spec ->
            {:ok, [spec.name]}
        end
    end
  end

  defp eject_all(names, site, theme, force?) do
    results =
      Enum.map(names, fn name ->
        eject_one(name, site, theme, force?)
      end)

    case Enum.find(results, &match?({:error, _}, &1)) do
      {:error, _} = error -> error
      nil -> {:ok, %{ejected: Enum.map(results, fn {:ok, entry} -> entry end)}}
    end
  end

  defp eject_one(name, site, theme, force?) do
    template_file = Theme.template_path(theme, name)
    overlay = Resolver.overlay_path(site, theme, name)

    cond do
      is_nil(overlay) ->
        {:error,
         %Error{
           code: :site_local_theme,
           message:
             "#{theme.name} already lives in this site — edit its templates directly at " <>
               "#{Theme.template_path(theme, name)}",
           exit: 2
         }}

      not File.exists?(template_file) ->
        {:error,
         %Error{code: :unknown_template, message: "theme has no template #{name}", exit: 2}}

      File.exists?(overlay) and not force? ->
        {:error,
         %Error{
           code: :overlay_exists,
           message: "#{overlay} already exists — pass --force to overwrite"
         }}

      true ->
        content = File.read!(template_file)
        File.mkdir_p!(Path.dirname(overlay))
        File.write!(overlay, Provenance.stamp(content, theme.name, theme.version))
        {:ok, %{template: Atom.to_string(name), path: overlay}}
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
