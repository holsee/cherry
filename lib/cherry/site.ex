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
            search: [
              type: {:in, ["cherry", "pagefind"]},
              doc:
                "Optional search: `\"cherry\"` builds the index in-process (no Node), " <>
                  "`\"pagefind\"` shells out to Pagefind."
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
            ],
            nav: [
              type:
                {:list,
                 {:keyword_list,
                  [
                    label: [type: :string, required: true],
                    href: [type: :string, required: true],
                    position: [type: {:in, [:start, :end]}, default: :end]
                  ]}},
              default: [],
              doc:
                "Extra nav entries. `position: :end` (the default) appends an entry " <>
                  "after the built-ins (Blog, then Portfolio/CV when present); " <>
                  "`position: :start` places it before them. `href` is site-relative " <>
                  "(\"guides/\" — base_path is applied) or absolute (http…), passed verbatim."
            ],
            deploy_paths: [
              type: {:list, :string},
              default: [],
              doc:
                "Root-relative path prefixes the deployment serves from beside " <>
                  "this build (a sibling build mounted under the same origin, " <>
                  ~s{e.g. `deploy_paths: ["t/"]` for a theme exhibition at /t/). } <>
                  "`cherry check` treats internal links under them as satisfied."
            ],
            tokens: [
              type: {:custom, __MODULE__, :validate_tokens, []},
              default: [],
              doc:
                ~s(Theme token overrides, e.g. `tokens: ["--color-accent": "#7c3aed"]`. ) <>
                  "Every key must exist in the active theme's token manifest " <>
                  "(`cherry theme.tokens` lists them); a value applies to both the " <>
                  "light and dark renditions unless written as `light-dark(a, b)`."
            ]
          )

  alias Cherry.Site.Icons

  @enforce_keys [:title, :url, :base_path, :root, :output]
  defstruct [
    :title,
    :url,
    :base_path,
    :theme,
    :search,
    :description,
    :author,
    :social_image,
    :root,
    :output,
    nav: [],
    deploy_paths: [],
    tokens: [],
    custom_css: nil,
    icons: %Icons{}
  ]

  @type nav_entry :: %{label: String.t(), href: String.t(), position: :start | :end}

  @type t :: %__MODULE__{
          title: String.t(),
          url: String.t(),
          base_path: String.t(),
          theme: String.t(),
          search: String.t() | nil,
          description: String.t() | nil,
          author: String.t(),
          social_image: String.t() | nil,
          nav: [nav_entry()],
          deploy_paths: [String.t()],
          tokens: [{String.t(), String.t()}],
          custom_css: String.t() | nil,
          icons: Icons.t(),
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
           search: validated[:search],
           description: validated[:description],
           author: Keyword.get(validated, :author, validated[:title]),
           social_image: validated[:social_image],
           nav: Enum.map(validated[:nav], &Map.new/1),
           deploy_paths: validated[:deploy_paths],
           tokens: validated[:tokens],
           custom_css: detect_custom_css(root),
           icons: Icons.detect(root),
           root: root,
           output: Keyword.get(opts, :output, Path.join(root, "_site"))
         }}

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, "#{@config_file}: #{Exception.message(error)}"}
    end
  end

  @doc false
  # NimbleOptions custom validator: a keyword list of quoted-atom token
  # names (`"--color-accent": "#7c3aed"`) mapping to string values. Kept
  # as ordered `{name, value}` string pairs; whether each name exists is
  # the active theme's call, checked when the theme is loaded.
  @spec validate_tokens(term()) :: {:ok, [{String.t(), String.t()}]} | {:error, String.t()}
  def validate_tokens(value) do
    cond do
      not (is_list(value) and Keyword.keyword?(value)) ->
        {:error, "expected a keyword list like [\"--color-accent\": \"#7c3aed\"]"}

      bad = Enum.find(value, fn {k, _v} -> not valid_token_name?(k) end) ->
        {name, _value} = bad
        {:error, "#{inspect(name)} is not a token name — token names start with `--`"}

      bad = Enum.find(value, fn {_k, v} -> not (is_binary(v) and String.trim(v) != "") end) ->
        {name, _value} = bad
        {:error, "#{name} needs a non-empty string value"}

      bad = Enum.find(value, fn {_k, v} -> String.match?(v, ~r/[<>{};]/) end) ->
        {name, _value} = bad
        {:error, "#{name} carries CSS structure characters (<>{};) — a value only"}

      true ->
        {:ok, Enum.map(value, fn {k, v} -> {Atom.to_string(k), String.trim(v)} end)}
    end
  end

  defp valid_token_name?(key) when is_atom(key) do
    key |> Atom.to_string() |> String.match?(~r/^--[a-zA-Z][\w-]*$/)
  end

  # Rung 3 of the customization ladder: `assets/custom.css` in the site
  # root loads after everything else, always. Detection here (like icons)
  # so themes and stages just read the struct.
  defp detect_custom_css(root) do
    if File.regular?(Path.join([root, "assets", "custom.css"])), do: "assets/custom.css"
  end

  # "/repo" and "repo/" both mean "/repo/"; "" and "/" both mean "/".
  defp normalize_base_path(base_path) do
    trimmed = String.trim(base_path, "/")
    if trimmed == "", do: "/", else: "/" <> trimmed <> "/"
  end
end
