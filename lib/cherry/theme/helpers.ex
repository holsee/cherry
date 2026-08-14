defmodule Cherry.Theme.Helpers do
  @moduledoc """
  Functions available to theme templates.

  Templates opt in with `<% import Cherry.Theme.Helpers %>` at the top —
  explicit, visible to theme authors, no hidden magic in the renderer.
  """

  @doc "Escapes text for safe interpolation into HTML."
  @spec h(String.Chars.t()) :: String.t()
  def h(value) do
    value
    |> to_string()
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  @doc "Formats a date for display, e.g. `January 15, 2026`."
  @spec format_date(Date.t()) :: String.t()
  def format_date(%Date{} = date), do: Calendar.strftime(date, "%B %-d, %Y")

  @doc """
  Site-rooted href for an output-relative location — respects `base_path`.

      href(@site, "blog/")  #=> "/blog/" or "/repo/blog/"
  """
  @spec href(Cherry.Site.t(), String.t()) :: String.t()
  defdelegate href(site, rel), to: Cherry.Site

  @doc "URL-safe slug for a tag name."
  @spec tag_slug(String.t()) :: String.t()
  def tag_slug(tag) do
    tag
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
