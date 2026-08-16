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
  defstruct [
    :site,
    :theme,
    page_title: "",
    head_extra: "",
    nav: [],
    search: nil,
    page_class: ""
  ]

  @type t :: %__MODULE__{
          site: Site.t(),
          theme: Theme.t(),
          page_title: String.t(),
          head_extra: String.t(),
          nav: [NavItem.t()],
          search: String.t() | nil,
          page_class: String.t()
        }

  @doc """
  Derives a page's context from the base: same site/theme/nav.

  `page_class` is the layout's body class (`page-home`, `page-guides`,
  `page-post`, …) so a theme can restyle whole sections without new
  templates.

  `search` carries the configured engine (`"cherry"`, `"pagefind"`, or
  `nil`) rather than a boolean, because the two engines need different
  markup and assets; `<%= if @search do %>` still reads as "search is
  on" in a template.
  """
  @spec page(t(), String.t(), String.t(), String.t()) :: t()
  def page(%__MODULE__{} = context, page_title, head_extra, page_class \\ "") do
    %__MODULE__{context | page_title: page_title, head_extra: head_extra, page_class: page_class}
  end
end
