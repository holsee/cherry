defmodule Cherry.Theme.RenderContext do
  @moduledoc """
  Everything the layout wrap needs beyond the inner template's own
  assigns: the site, the active theme, the page title, the
  framework-owned SEO head block, and the navigation.

  One value instead of a growing argument list — pages differ only in
  title and head, so `for/3` derives a page's context from the base.
  """

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.NavItem

  @enforce_keys [:site, :theme]
  defstruct [:site, :theme, page_title: "", head_extra: "", nav: []]

  @type t :: %__MODULE__{
          site: Site.t(),
          theme: Theme.t(),
          page_title: String.t(),
          head_extra: String.t(),
          nav: [NavItem.t()]
        }

  @doc "Derives a page's context from the base: same site/theme/nav."
  @spec page(t(), String.t(), String.t()) :: t()
  def page(%__MODULE__{} = context, page_title, head_extra) do
    %__MODULE__{context | page_title: page_title, head_extra: head_extra}
  end
end
