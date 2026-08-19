defmodule Cherry.Theme.Resolver do
  @moduledoc """
  The three-level template lookup: site overlay → theme → framework.

  Three levels, never more (Hugo's specificity matrix is the cautionary
  tale), and always printable via `cherry theme.which`. Overlays are keyed
  per-theme (`themes/<theme-name>/templates/…`) so swapping themes never
  silently applies overrides written for a different theme.
  """

  alias Cherry.Site
  alias Cherry.Theme

  @levels [:site_overlay, :theme, :framework]

  @doc """
  Where a site's overlay file for this theme + template would live, or
  `nil` when the theme is site-local.

  An overlay only means something relative to an *installed* theme. A
  theme that lives inside the site — what `cherry gen.theme` writes, and
  what `theme: "themes/mine"` selects — owns its templates outright, so
  the overlay path would land on the theme's own files and report every
  one of them as untracked drift.
  """
  @spec overlay_path(Site.t(), Theme.t(), atom()) :: Path.t() | nil
  def overlay_path(%Site{root: root} = site, %Theme{name: theme_name} = theme, name) do
    unless site_local?(site, theme) do
      Path.join([root, "themes", theme_name, "templates", "#{name}.html.eex"])
    end
  end

  @doc "Whether this theme is loaded from inside the site itself."
  @spec site_local?(Site.t(), Theme.t()) :: boolean()
  def site_local?(%Site{root: site_root}, %Theme{root: theme_root}) do
    site = normalize(site_root)
    theme = normalize(theme_root)

    theme != site and String.starts_with?(theme, site <> "/")
  end

  defp normalize(path) do
    path |> Path.expand() |> String.replace("\\", "/") |> String.trim_trailing("/")
  end

  @doc """
  The full lookup chain for a template: `{level, path, exists?}` in
  priority order. The first existing entry wins.

  Each level offers two candidates — `<name>.html.heex`, then
  `<name>.html.eex` — so a HEEx rewrite wins over the EEx original at
  the same level, and a site overlay in either language beats the theme.
  """
  @spec chain(Site.t(), Theme.t(), atom()) :: [{atom(), Path.t(), boolean()}]
  def chain(%Site{} = site, %Theme{} = theme, name) do
    for level <- @levels,
        base = level_path(level, site, theme, name),
        not is_nil(base),
        path <- [heex_variant(base), base] do
      {level, path, File.exists?(path)}
    end
  end

  @doc "The `.html.heex` twin of an `.html.eex` template path."
  @spec heex_variant(Path.t()) :: Path.t()
  def heex_variant(path), do: String.replace_suffix(path, ".html.eex", ".html.heex")

  @doc "Resolves a template to the winning `{level, path}`."
  @spec resolve(Site.t(), Theme.t(), atom()) :: {:ok, {atom(), Path.t()}} | {:error, String.t()}
  def resolve(%Site{} = site, %Theme{} = theme, name) do
    case Enum.find(chain(site, theme, name), fn {_level, _path, exists?} -> exists? end) do
      {level, path, true} -> {:ok, {level, path}}
      nil -> {:error, "no template #{name} in overlay, theme #{theme.name}, or framework"}
    end
  end

  defp level_path(:site_overlay, site, theme, name), do: overlay_path(site, theme, name)
  defp level_path(:theme, _site, theme, name), do: Theme.template_path(theme, name)

  defp level_path(:framework, _site, _theme, name) do
    Path.join([Theme.default_root(), "templates", "#{name}.html.eex"])
  end
end
