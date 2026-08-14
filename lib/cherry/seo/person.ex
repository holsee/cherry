defmodule Cherry.SEO.Person do
  @moduledoc """
  JSON-LD `Person` derived from the portfolio (DESIGN.md §4): the
  portfolio *is* the structured data. Emitted on the timeline page.
  """

  alias Cherry.Portfolio
  alias Cherry.Portfolio.Position
  alias Cherry.Site

  @doc ~S(The `<script type="application/ld+json">` block, or `""` without a profile.)
  @spec json_ld(Site.t(), Portfolio.t()) :: String.t()
  def json_ld(_site, %Portfolio{profile: nil}), do: ""

  def json_ld(%Site{} = site, %Portfolio{profile: profile} = portfolio) do
    person =
      %{
        "@context" => "https://schema.org",
        "@type" => "Person",
        "name" => profile.name,
        "url" => Site.abs_url(site, "portfolio/")
      }
      |> maybe_put("description", profile.headline)
      |> maybe_put("email", profile.email)
      |> maybe_put("sameAs", links(profile))
      |> maybe_put("jobTitle", job_title(portfolio))
      |> maybe_put("worksFor", works_for(portfolio))
      |> maybe_put("alumniOf", alumni_of(portfolio))
      |> maybe_put("knowsAbout", knows_about(portfolio))

    ~s(<script type="application/ld+json">#{JSON.encode!(person)}</script>\n)
  end

  defp links(profile) do
    case Enum.map(profile.links, & &1.url) do
      [] -> nil
      urls -> urls
    end
  end

  defp job_title(portfolio) do
    case current_position(portfolio) do
      nil -> nil
      position -> position.title
    end
  end

  defp works_for(portfolio) do
    case current_position(portfolio) do
      nil -> nil
      position -> %{"@type" => "Organization", "name" => position.org}
    end
  end

  defp current_position(portfolio) do
    Enum.find(portfolio.positions, &Position.current?/1)
  end

  defp alumni_of(portfolio) do
    case portfolio.education do
      [] ->
        nil

      education ->
        education
        |> Enum.map(& &1.institution)
        |> Enum.uniq()
        |> Enum.map(&%{"@type" => "EducationalOrganization", "name" => &1})
    end
  end

  defp knows_about(portfolio) do
    case Portfolio.tags(portfolio) do
      [] -> nil
      tags -> tags
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
