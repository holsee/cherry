defmodule Cherry.Site do
  @moduledoc """
  A Cherry site: the validated configuration plus its filesystem roots.

  Configuration lives in `cherry.exs` at the site root — a plain keyword
  list, evaluated at build time so it works identically in project mode and
  binary mode (ADR 0002). The schema below is the source of truth; it is
  introspectable because agents ask before they write.
  """

  @config_file "cherry.exs"

  @schema NimbleOptions.new!(
            title: [
              type: :string,
              required: true,
              doc: "Site title, used by themes and feeds."
            ],
            url: [
              type: :string,
              required: true,
              doc: "Canonical origin, e.g. `https://example.com` — no trailing slash."
            ],
            base_path: [
              type: :string,
              default: "/",
              doc: "Base path when hosted under a subpath (GitHub project pages)."
            ],
            theme: [
              type: :string,
              default: "default",
              doc: "\"default\" for the built-in theme, or a theme directory."
            ]
          )

  @enforce_keys [:title, :url, :base_path, :root, :output]
  defstruct [:title, :url, :base_path, :theme, :root, :output]

  @type t :: %__MODULE__{
          title: String.t(),
          url: String.t(),
          base_path: String.t(),
          theme: String.t(),
          root: Path.t(),
          output: Path.t()
        }

  @doc """
  Loads and validates `cherry.exs` from `root`.

  Options: `:output` overrides the output directory (default `root/_site`).
  Errors are strings that name the file and the offending field.
  """
  @spec load(Path.t(), keyword()) :: {:ok, t()} | {:error, String.t()}
  def load(root, opts \\ []) do
    path = Path.join(root, @config_file)

    if File.exists?(path) do
      {config, _binding} = Code.eval_file(path)
      validate(config, root, opts)
    else
      {:error, "no #{@config_file} found in #{root}"}
    end
  end

  @doc "The site config schema, for introspection and docs."
  @spec schema() :: NimbleOptions.t()
  def schema, do: @schema

  defp validate(config, root, opts) do
    case NimbleOptions.validate(config, @schema) do
      {:ok, validated} ->
        {:ok,
         %__MODULE__{
           title: validated[:title],
           url: validated[:url],
           base_path: validated[:base_path],
           theme: validated[:theme],
           root: root,
           output: Keyword.get(opts, :output, Path.join(root, "_site"))
         }}

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, "#{@config_file}: #{Exception.message(error)}"}
    end
  end
end
