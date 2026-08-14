defmodule Cherry.Site do
  @moduledoc """
  A Cherry site: the validated configuration plus its filesystem roots.

  Configuration lives in `cherry.exs` at the site root — a plain keyword
  list, evaluated at build time so it works identically in project mode and
  binary mode (ADR 0002). The schema below is the source of truth; it is
  introspectable because agents ask before they write.

  All URL building goes through `href/2` and `abs_url/2` so every emitted
  URL respects `base_path` (the GitHub project-pages case) — no template or
  stage ever concatenates URL strings itself.
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
            ],
            description: [
              type: :string,
              doc: "Site description for meta tags and the feed subtitle."
            ],
            author: [
              type: :string,
              doc: "Feed author name. Defaults to the site title."
            ],
            social_image: [
              type: :string,
              doc: "Site-relative path to a fallback social card image, e.g. `card.png`."
            ]
          )

  @enforce_keys [:title, :url, :base_path, :root, :output]
  defstruct [
    :title,
    :url,
    :base_path,
    :theme,
    :description,
    :author,
    :social_image,
    :root,
    :output
  ]

  @type t :: %__MODULE__{
          title: String.t(),
          url: String.t(),
          base_path: String.t(),
          theme: String.t(),
          description: String.t() | nil,
          author: String.t(),
          social_image: String.t() | nil,
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

  @doc """
  Site-rooted path for an output-relative location: respects `base_path`.

      href(site, "blog/")   #=> "/blog/" or "/repo/blog/"
      href(site, "")        #=> "/" or "/repo/"
  """
  @spec href(t(), String.t()) :: String.t()
  def href(%__MODULE__{base_path: base_path}, rel) do
    base_path <> rel
  end

  @doc "Absolute URL for an output-relative location."
  @spec abs_url(t(), String.t()) :: String.t()
  def abs_url(%__MODULE__{} = site, rel) do
    site.url <> href(site, rel)
  end

  defp validate(config, root, opts) do
    case NimbleOptions.validate(config, @schema) do
      {:ok, validated} ->
        {:ok,
         %__MODULE__{
           title: validated[:title],
           url: String.trim_trailing(validated[:url], "/"),
           base_path: normalize_base_path(validated[:base_path]),
           theme: validated[:theme],
           description: validated[:description],
           author: Keyword.get(validated, :author, validated[:title]),
           social_image: validated[:social_image],
           root: root,
           output: Keyword.get(opts, :output, Path.join(root, "_site"))
         }}

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, "#{@config_file}: #{Exception.message(error)}"}
    end
  end

  # "/repo" and "repo/" both mean "/repo/"; "" and "/" both mean "/".
  defp normalize_base_path(base_path) do
    trimmed = String.trim(base_path, "/")
    if trimmed == "", do: "/", else: "/" <> trimmed <> "/"
  end
end
