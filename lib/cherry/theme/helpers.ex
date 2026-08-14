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

  @doc "Formats a month for display, e.g. `Apr 2015`."
  @spec format_month(Date.t()) :: String.t()
  def format_month(%Date{} = date), do: Calendar.strftime(date, "%b %Y")

  @doc ~S(A date span: `Jan 2020 — present`, `Jan 2020 — May 2022`, or `""`.)
  @spec format_range(Date.t() | nil, Date.t() | nil) :: String.t()
  def format_range(nil, nil), do: ""
  def format_range(nil, %Date{} = ended), do: format_month(ended)
  def format_range(%Date{} = started, nil), do: format_month(started) <> " — present"

  def format_range(%Date{} = started, %Date{} = ended) do
    format_month(started) <> " — " <> format_month(ended)
  end

  @doc """
  Site-rooted href for an output-relative location — respects `base_path`.

      href(@site, "blog/")  #=> "/blog/" or "/repo/blog/"
  """
  @spec href(Cherry.Site.t(), String.t()) :: String.t()
  defdelegate href(site, rel), to: Cherry.Site

  @doc """
  The CV bullets for an entry: the `cv:` block's curated highlights win
  over the timeline ones (curation, not duplication — DESIGN.md §4).
  """
  @spec cv_highlights(%{cv: Cherry.Portfolio.Curation.t() | nil, highlights: [String.t()]}) ::
          [String.t()]
  def cv_highlights(%{cv: %Cherry.Portfolio.Curation{highlights: [_ | _] = curated}}), do: curated
  def cv_highlights(%{highlights: highlights}), do: highlights

  @doc "URL-safe slug for a tag name."
  @spec tag_slug(String.t()) :: String.t()
  def tag_slug(tag) do
    tag
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
