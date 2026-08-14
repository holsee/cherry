defmodule Cherry.CV do
  @moduledoc """
  The CV: the employer-shaped projection of the portfolio (DESIGN.md §4).

  Strictly a *projection* — the same entries the timeline shows, curated
  by their `cv:` blocks and ordered by weight, never a second dataset.
  Skills are derived from tags across positions and projects, weighted
  by duration and recency, each linking back to its story page — a
  paper CV claims; this one shows.

  `today` comes from the build options (time is an input, ADR 0005), so
  open-ended ranges and the freshness line stay deterministic.
  """

  alias Cherry.CV.Skill
  alias Cherry.Portfolio
  alias Cherry.Portfolio.{Education, OpenSource, Position, Profile, Project, Talk}

  @enforce_keys [:profile, :updated]
  defstruct [
    :profile,
    :updated,
    positions: [],
    projects: [],
    talks: [],
    oss: [],
    education: [],
    skills: []
  ]

  @type t :: %__MODULE__{
          profile: Profile.t(),
          updated: Date.t(),
          positions: [Position.t()],
          projects: [Project.t()],
          talks: [Talk.t()],
          oss: [OpenSource.t()],
          education: [Education.t()],
          skills: [Skill.t()]
        }

  @doc """
  Projects the portfolio onto the CV, or `nil` without a profile —
  a CV without a person makes no sense.

  Entries opt in via `cv.include` (education is included by default:
  leaving a degree off a CV is the exception, not the rule).
  """
  @spec project(Portfolio.t(), Date.t()) :: t() | nil
  def project(%Portfolio{profile: nil}, _today), do: nil

  def project(%Portfolio{profile: profile} = portfolio, today) do
    positions = included(portfolio.positions, &Position.sort_key/1)
    projects = included(portfolio.projects, &Project.sort_key/1)

    %__MODULE__{
      profile: profile,
      updated: updated(portfolio, profile),
      positions: positions,
      projects: projects,
      talks: included(portfolio.talks, &Talk.sort_key/1),
      oss: included(portfolio.oss, &OpenSource.sort_key/1),
      education: included_education(portfolio.education),
      skills: Skill.derive(positions ++ projects, today)
    }
  end

  # cv.include opts an entry in; weight breaks ties above recency.
  defp included(entries, sort_key) do
    entries
    |> Enum.filter(&(&1.cv != nil and &1.cv.include))
    |> Enum.sort_by(&{&1.cv.weight, sort_key.(&1)}, :desc)
  end

  defp included_education(education) do
    Enum.reject(education, &(&1.cv != nil and not &1.cv.include))
  end

  # Freshness from content, never the clock: an explicit `updated:` in
  # portfolio.yaml wins; otherwise the newest date any entry carries.
  defp updated(_portfolio, %Profile{updated: %Date{} = updated}), do: updated

  defp updated(portfolio, _profile) do
    portfolio
    |> Portfolio.entries()
    |> Enum.flat_map(&entry_dates/1)
    |> Enum.max(Date, fn -> ~D[1970-01-01] end)
  end

  defp entry_dates(%Talk{date: date}), do: [date]
  defp entry_dates(%OpenSource{}), do: []

  defp entry_dates(%{started: started, ended: ended}),
    do: Enum.reject([started, ended], &is_nil/1)
end
