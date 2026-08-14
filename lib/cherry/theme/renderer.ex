defmodule Cherry.Theme.Renderer do
  @moduledoc """
  Renders theme templates: runtime-evaluated EEx, so themes work
  identically in project mode and binary mode (ADR 0002/0004).
  """

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.{RenderContext, Resolver}

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

  The context carries the layout's own assigns: page title, the
  framework-owned SEO head block (`Cherry.SEO.Head`, interpolated
  verbatim inside `<head>`), and the navigation.
  """
  @spec render_in_layout(RenderContext.t(), atom(), keyword()) ::
          {:ok, String.t()} | {:error, String.t()}
  def render_in_layout(%RenderContext{site: site, theme: theme} = context, name, assigns) do
    with {:ok, inner} <- render(site, theme, name, assigns) do
      render(site, theme, :layout,
        site: site,
        inner: inner,
        page_title: context.page_title,
        head_extra: context.head_extra,
        nav: context.nav,
        search: context.search?,
        page_class: context.page_class
      )
    end
  end
end
