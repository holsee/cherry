defmodule Cherry.Commands.ThemeList do
  @doc_text """
  Shows the active theme: contract, template inventory with where each
  template resolves from, token manifest, and the state of any site
  overlays (fresh / stale / untracked).

  ## Usage

      mix cherry.theme.list [--source DIR] [--json]
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Theme
  alias Cherry.Theme.{Provenance, Resolver}

  @impl Cherry.CLI.Command
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
      templates =
        Enum.map(theme.templates, fn spec ->
          {level, path} = winning(site, theme, spec.name)

          %{
            name: Atom.to_string(spec.name),
            assigns: Enum.map(spec.assigns, &Atom.to_string/1),
            doc: spec.doc,
            resolves_from: Atom.to_string(level),
            path: path,
            overlay: overlay_state(site, theme, spec.name)
          }
        end)

      {:ok,
       %{
         name: theme.name,
         version: theme.version,
         contract: theme.contract,
         root: theme.root,
         description: theme.description,
         templates: templates,
         tokens:
           Enum.map(theme.tokens, fn {token, spec} ->
             %{
               name: Atom.to_string(token),
               default: Keyword.get(spec, :default),
               dark: Keyword.get(spec, :dark),
               doc: Keyword.get(spec, :doc)
             }
           end)
       }}
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(data) do
    header = "#{data.name} #{data.version} (contract #{data.contract})\n  #{data.root}"

    templates =
      Enum.map(data.templates, fn template ->
        state = if template.overlay, do: " [overlay: #{template.overlay}]", else: ""

        "  #{String.pad_trailing(template.name, 10)} #{template.resolves_from}#{state}" <>
          "\n    assigns: #{Enum.join(template.assigns, ", ")}"
      end)

    tokens =
      case data.tokens do
        [] -> ["  (none yet — the design pass fills these in)"]
        list -> Enum.map(list, &"  #{&1.name} = #{inspect(&1.default)} — #{&1.doc}")
      end

    Enum.join([header, "templates:"] ++ templates ++ ["tokens:"] ++ tokens, "\n")
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

  defp winning(site, theme, name) do
    case Resolver.resolve(site, theme, name) do
      {:ok, {level, path}} -> {level, path}
      {:error, _} -> {:missing, ""}
    end
  end

  defp overlay_state(site, theme, name) do
    overlay = Resolver.overlay_path(site, theme, name)

    if overlay && File.exists?(overlay) do
      current = Theme.template_path(theme, name)
      current_content = if File.exists?(current), do: File.read!(current), else: ""

      overlay
      |> File.read!()
      |> Provenance.status(current_content)
      |> Atom.to_string()
    end
  end
end
