defmodule Cherry.CV.JsonResume do
  @moduledoc """
  `/cv.json` in the JSON Resume standard schema — ATS tools and agents
  consume it; the same projection as the web CV, machine-shaped.
  """

  alias Cherry.CV
  alias Cherry.Site

  @doc "Renders the CV as a JSON Resume document."
  @spec render(CV.t(), Site.t()) :: String.t()
  def render(%CV{} = cv, %Site{} = site) do
    %{
      "$schema" =>
        "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json",
      "basics" => basics(cv, site),
      "work" => Enum.map(cv.positions, &work/1),
      "projects" => Enum.map(cv.projects, &project/1),
      "education" => Enum.map(cv.education, &education/1),
      "skills" => Enum.map(cv.skills, &%{"name" => &1.tag}),
      "meta" => %{
        "canonical" => Site.abs_url(site, "cv.json"),
        "lastModified" => Date.to_iso8601(cv.updated)
      }
    }
    |> prune()
    |> Cherry.StableJSON.encode!()
  end

  defp basics(cv, site) do
    %{
      "name" => cv.profile.name,
      "label" => cv.profile.headline,
      "email" => cv.profile.email,
      "url" => Site.abs_url(site, "cv/"),
      "location" => cv.profile.location && %{"city" => cv.profile.location},
      "profiles" => Enum.map(cv.profile.links, &%{"network" => &1.label, "url" => &1.url})
    }
    |> prune()
  end

  defp work(position) do
    %{
      "name" => position.org,
      "position" => position.title,
      "location" => position.location,
      "startDate" => Date.to_iso8601(position.started),
      "endDate" => position.ended && Date.to_iso8601(position.ended),
      "highlights" => highlights(position)
    }
    |> prune()
  end

  defp project(project) do
    %{
      "name" => project.title,
      "startDate" => project.started && Date.to_iso8601(project.started),
      "endDate" => project.ended && Date.to_iso8601(project.ended),
      "url" => project.links |> Enum.map(& &1.url) |> List.first(),
      "highlights" => highlights(project)
    }
    |> prune()
  end

  defp education(education) do
    %{
      "institution" => education.institution,
      "area" => education.title,
      "startDate" => education.started && Date.to_iso8601(education.started),
      "endDate" => education.ended && Date.to_iso8601(education.ended)
    }
    |> prune()
  end

  # The cv block's punchy bullets win over the timeline highlights.
  defp highlights(entry) do
    case entry.cv.highlights do
      [] -> entry.highlights
      curated -> curated
    end
  end

  defp prune(map) do
    map
    |> Enum.reject(fn {_key, value} -> value in [nil, [], %{}] end)
    |> Map.new()
  end
end
