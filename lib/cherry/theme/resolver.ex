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

  @doc "Where a site's overlay file for this theme + template would live."
  @spec overlay_path(Site.t(), Theme.t(), atom()) :: Path.t()
  def overlay_path(%Site{root: root}, %Theme{name: theme_name}, name) do
    Path.join([root, "themes", theme_name, "templates", "#{name}.html.eex"])
  end

  @doc """
  The full lookup chain for a template: `{level, path, exists?}` in
  priority order. The first existing entry wins.
  """
  @spec chain(Site.t(), Theme.t(), atom()) :: [{atom(), Path.t(), boolean()}]
  def chain(%Site{} = site, %Theme{} = theme, name) do
    Enum.map(@levels, fn level ->
      path = level_path(level, site, theme, name)
      {level, path, File.exists?(path)}
    end)
  end

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
