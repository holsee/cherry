defmodule Cherry.Theme.Renderer do
  @moduledoc """
  Renders theme templates: runtime-evaluated EEx, so themes work
  identically in project mode and binary mode (ADR 0002/0004).
  """

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.Resolver

  @doc """
  Renders a named template through the lookup chain with the given assigns.
  """
  @spec render(Site.t(), Theme.t(), atom(), keyword()) ::
          {:ok, String.t()} | {:error, String.t()}
  def render(%Site{} = site, %Theme{} = theme, name, assigns) do
    with {:ok, {_level, path}} <- Resolver.resolve(site, theme, name) do
      {:ok, EEx.eval_file(path, assigns: assigns)}
    end
  end

  @doc """
  Renders a content template and wraps it in the theme's `layout`.
  """
  @spec render_in_layout(Site.t(), Theme.t(), atom(), keyword(), String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def render_in_layout(%Site{} = site, %Theme{} = theme, name, assigns, page_title) do
    with {:ok, inner} <- render(site, theme, name, assigns) do
      render(site, theme, :layout,
        site: site,
        inner: inner,
        page_title: page_title
      )
    end
  end
end
