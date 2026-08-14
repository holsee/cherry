defmodule Cherry.Theme do
  @moduledoc """
  A theme: a directory carrying a `theme.exs` manifest (ADR 0004).

  The manifest declares the contract version, the template inventory
  (fixed names, fixed assigns — that is *why* swapping works), and the
  token manifest. Themes are plain directories so binary-mode sites get
  full themes; the default theme ships in Cherry's `priv/` and goes
  through the exact same loader — theme #1, not privileged code.
  """

  alias Cherry.Site
  alias Cherry.Theme.TemplateSpec

  @manifest_file "theme.exs"
  @contract_major "1"
  @required_templates ~w(layout page post post_list tag not_found)a

  @manifest_schema NimbleOptions.new!(
                     name: [type: :string, required: true],
                     version: [type: :string, required: true],
                     description: [type: :string],
                     cherry_contract: [type: :string, required: true],
                     templates: [type: :keyword_list, required: true],
                     tokens: [type: :keyword_list, default: []]
                   )

  @enforce_keys [:name, :version, :contract, :root, :templates]
  defstruct name: nil,
            version: nil,
            description: nil,
            contract: nil,
            root: nil,
            templates: [],
            tokens: []

  @type t :: %__MODULE__{
          name: String.t(),
          version: String.t(),
          description: String.t() | nil,
          contract: String.t(),
          root: Path.t(),
          templates: [TemplateSpec.t()],
          tokens: keyword()
        }

  @doc "The template names every contract-1.x theme must provide."
  @spec required_templates() :: [atom()]
  def required_templates, do: @required_templates

  @doc "The directory of the built-in default theme."
  @spec default_root() :: Path.t()
  def default_root, do: builtin_root("default")

  @doc "The directory a built-in theme of this name would live in."
  @spec builtin_root(String.t()) :: Path.t()
  def builtin_root(name) do
    :cherry |> :code.priv_dir() |> Path.join("themes/#{name}")
  end

  @doc "Names of the official themes shipped in Cherry's priv/, sorted."
  @spec builtin_names() :: [String.t()]
  def builtin_names do
    themes = :cherry |> :code.priv_dir() |> Path.join("themes")

    case File.ls(themes) do
      {:ok, names} -> names |> Enum.filter(&File.dir?(Path.join(themes, &1))) |> Enum.sort()
      {:error, _} -> []
    end
  end

  @doc """
  Resolves and loads the active theme for a site.

  A bare name matching an official theme (`"default"`, `"cherrybomb"`)
  loads the built-in; any other value is a directory (relative to the
  site root) containing a `theme.exs`.
  """
  @spec load_active(Site.t()) :: {:ok, t()} | {:error, String.t()}
  def load_active(%Site{theme: theme, root: root}) do
    if bare_name?(theme) and File.dir?(builtin_root(theme)) do
      load(builtin_root(theme))
    else
      load(Path.expand(theme, root))
    end
  end

  defp bare_name?(theme) do
    not String.contains?(theme, ["/", "\\", "."])
  end

  @doc "Loads and conformance-checks a theme directory."
  @spec load(Path.t()) :: {:ok, t()} | {:error, String.t()}
  def load(root) do
    manifest = Path.join(root, @manifest_file)

    with {:ok, config} <- read_manifest(manifest, root),
         {:ok, validated} <- validate_manifest(config, manifest),
         {:ok, theme} <- build(validated, root) do
      conformance_check(theme)
    end
  end

  @doc "Absolute path of a template file inside this theme."
  @spec template_path(t(), atom()) :: Path.t()
  def template_path(%__MODULE__{root: root}, name) do
    Path.join([root, "templates", "#{name}.html.eex"])
  end

  defp read_manifest(manifest, root) do
    if File.exists?(manifest) do
      {config, _binding} = Code.eval_file(manifest)
      {:ok, config}
    else
      {:error, "no #{@manifest_file} found in #{root} — not a theme directory"}
    end
  end

  defp validate_manifest(config, manifest) do
    case NimbleOptions.validate(config, @manifest_schema) do
      {:ok, validated} -> {:ok, validated}
      {:error, error} -> {:error, "#{manifest}: #{Exception.message(error)}"}
    end
  end

  defp build(validated, root) do
    contract = validated[:cherry_contract]

    if String.starts_with?(contract, @contract_major <> ".") do
      {:ok,
       %__MODULE__{
         name: validated[:name],
         version: validated[:version],
         description: validated[:description],
         contract: contract,
         root: root,
         templates: TemplateSpec.from_manifest(validated[:templates]),
         tokens: validated[:tokens]
       }}
    else
      {:error,
       "theme #{validated[:name]} targets contract #{contract}; " <>
         "this Cherry speaks #{@contract_major}.x"}
    end
  end

  defp conformance_check(%__MODULE__{} = theme) do
    declared = Enum.map(theme.templates, & &1.name)

    missing_declarations = @required_templates -- declared

    missing_files =
      declared
      |> Enum.map(&{&1, template_path(theme, &1)})
      |> Enum.reject(fn {_name, path} -> File.exists?(path) end)
      |> Enum.map(fn {name, _path} -> name end)

    cond do
      missing_declarations != [] ->
        {:error,
         "theme #{theme.name} does not declare required template(s): " <>
           Enum.map_join(missing_declarations, ", ", &to_string/1)}

      missing_files != [] ->
        {:error,
         "theme #{theme.name} declares but does not ship template(s): " <>
           Enum.map_join(missing_files, ", ", &to_string/1)}

      true ->
        {:ok, theme}
    end
  end
end
