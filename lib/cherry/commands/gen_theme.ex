defmodule Cherry.Commands.GenTheme do
  @doc_text """
  Scaffolds a site-local theme from an official one.

  ## Usage

      mix cherry.gen.theme NAME [--from THEME] [--source DIR] [--json]

  Copies the official theme (`--from default`, `cherrybomb`, or
  `porcelain`) into `themes/NAME/` — manifest, templates, stylesheet,
  islands; templates a CSS-only theme inherits are materialised — and
  renames it. Point `cherry.exs` at it with `theme: "themes/NAME"` and
  every file is yours; the swap contract keeps the site building
  throughout.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Theme

  @impl Cherry.CLI.Command
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, from: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [name | _rest], opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    from = Keyword.get(opts, :from, "default")

    cond do
      not (name =~ ~r/\A[a-z0-9][a-z0-9_-]*\z/) ->
        {:error,
         %Error{code: :bad_name, message: "theme name must be a slug like my-theme", exit: 2}}

      from not in Theme.builtin_names() ->
        {:error,
         %Error{
           code: :unknown_theme,
           message: "--from #{from} is not official (#{Enum.join(Theme.builtin_names(), ", ")})",
           exit: 2
         }}

      true ->
        scaffold(source, name, from)
    end
  end

  def run(%Context{}) do
    {:error,
     %Error{code: :usage, message: "usage: cherry gen.theme NAME [--from THEME]", exit: 2}}
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{path: path, name: name}) do
    "Created #{path} — set `theme: #{inspect(Path.join("themes", name))}` " <>
      "in cherry.exs and edit away; the contract keeps the site building."
  end

  defp scaffold(source, name, from) do
    dest = Path.join([source, "themes", name])

    if File.exists?(dest) do
      {:error, %Error{code: :exists, message: "themes/#{name} already exists"}}
    else
      File.mkdir_p!(Path.dirname(dest))
      File.cp_r!(Theme.builtin_root(from), dest)
      rename_manifest(dest, name, from)
      materialise_inherited(dest, from)

      {:ok, %{path: Path.join("themes", name), name: name, from: from}}
    end
  end

  # An inheriting theme (contract 1.1) does not ship every declared
  # template; the fork should, so it stays self-contained and editable.
  # Copy the framework's file for each declared template the copy lacks.
  defp materialise_inherited(dest, from) do
    with {:ok, theme} <- Theme.load(Theme.builtin_root(from)) do
      for spec <- theme.templates,
          target = Path.join([dest, "templates", "#{spec.name}.html.eex"]),
          not File.exists?(target),
          source = Path.join([Theme.default_root(), "templates", "#{spec.name}.html.eex"]),
          File.exists?(source) do
        File.mkdir_p!(Path.dirname(target))
        File.cp!(source, target)
      end
    end

    :ok
  end

  # The copy keeps everything except the identity: name and a fresh version.
  defp rename_manifest(dest, name, from) do
    manifest = Path.join(dest, "theme.exs")

    content =
      manifest
      |> File.read!()
      |> String.replace(~s(name: "#{from}"), ~s(name: "#{name}"), global: false)

    File.write!(manifest, content)
  end
end
