defmodule Cherry.Portfolio.Timeline do
  @moduledoc """
  The chronological view of the developer story: dated entries mixed
  across collections, newest first, grouped by year.

  Open-source involvements carry no date — they are standing roles, not
  events — so the timeline leaves them out and the view renders them as
  their own section.
  """

  alias Cherry.Portfolio
  alias Cherry.Portfolio.{Education, Position, Project, Talk}

  defmodule Item do
    @moduledoc "One dated timeline entry with its kind made explicit."

    @enforce_keys [:kind, :date, :entry]
    defstruct [:kind, :date, :entry]

    @type t :: %__MODULE__{
            kind: :position | :project | :talk | :education,
            date: Date.t(),
            entry: Position.t() | Project.t() | Talk.t() | Education.t()
          }
  end

  @doc "Year groups, newest year first, items newest-first within."
  @spec groups(Portfolio.t()) :: [{integer(), [Item.t()]}]
  def groups(%Portfolio{} = portfolio) do
    portfolio
    |> items()
    |> Enum.group_by(& &1.date.year)
    |> Enum.sort_by(fn {year, _items} -> year end, :desc)
    |> Enum.map(fn {year, items} ->
      {year, Enum.sort_by(items, &{Date.to_erl(&1.date), sort_title(&1)}, :desc)}
    end)
  end

  defp items(portfolio) do
    Enum.map(portfolio.positions, &%Item{kind: :position, date: &1.started, entry: &1}) ++
      Enum.map(portfolio.projects, &%Item{kind: :project, date: project_date(&1), entry: &1}) ++
      Enum.map(portfolio.talks, &%Item{kind: :talk, date: &1.date, entry: &1}) ++
      Enum.map(portfolio.education, &%Item{kind: :education, date: education_date(&1), entry: &1})
  end

  # Projects and education may omit dates entirely; anchor undated
  # entries at the epoch so they sink to the bottom instead of crashing.
  defp project_date(%Project{started: nil, ended: nil}), do: ~D[1970-01-01]
  defp project_date(%Project{started: nil, ended: ended}), do: ended
  defp project_date(%Project{started: started}), do: started

  defp education_date(%Education{started: nil, ended: nil}), do: ~D[1970-01-01]
  defp education_date(%Education{started: nil, ended: ended}), do: ended
  defp education_date(%Education{started: started}), do: started

  defp sort_title(%Item{entry: %{title: title}}), do: title
end
