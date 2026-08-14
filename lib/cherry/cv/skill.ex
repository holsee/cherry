defmodule Cherry.CV.Skill do
  @moduledoc """
  A derived skill: a tag aggregated across CV positions and projects,
  weighted by duration and recency. The differentiator — each skill
  links to its story page, where the claim becomes evidence.
  """

  alias Cherry.Portfolio.{Position, Project}

  @enforce_keys [:tag, :years, :last_used]
  defstruct [:tag, :years, :last_used]

  @type t :: %__MODULE__{
          tag: String.t(),
          years: float(),
          last_used: Date.t()
        }

  @doc """
  Derives skills from CV-included positions and projects: per tag, the
  *calendar coverage* of every entry carrying it — overlapping spans
  are merged, never double-counted, so "6 yrs" means six years of the
  calendar, not six entry-years. Open ranges run to `today`. Ordered by
  recency then duration.
  """
  @spec derive([Position.t() | Project.t()], Date.t()) :: [t()]
  def derive(entries, today) do
    entries
    |> Enum.flat_map(fn entry -> Enum.map(entry.tags, &{&1, entry}) end)
    |> Enum.group_by(fn {tag, _entry} -> tag end, fn {_tag, entry} -> entry end)
    |> Enum.map(fn {tag, tagged} -> skill(tag, tagged, today) end)
    |> Enum.sort_by(&{Date.to_erl(&1.last_used), &1.years}, :desc)
  end

  defp skill(tag, entries, today) do
    spans =
      entries
      |> Enum.reject(&is_nil(&1.started))
      |> Enum.map(&{&1.started, &1.ended || today})
      |> Enum.sort_by(fn {from, to} -> {Date.to_erl(from), Date.to_erl(to)} end)

    days =
      spans |> merge_spans([]) |> Enum.map(fn {from, to} -> Date.diff(to, from) end) |> Enum.sum()

    last = entries |> Enum.map(&(&1.ended || today)) |> Enum.max(Date)

    %__MODULE__{tag: tag, years: Float.round(days / 365.25, 1), last_used: last}
  end

  defp merge_spans([], merged), do: Enum.reverse(merged)
  defp merge_spans([span | rest], []), do: merge_spans(rest, [span])

  defp merge_spans([{from, to} | rest], [{last_from, last_to} | merged]) do
    if Date.compare(from, last_to) in [:lt, :eq] do
      merge_spans(rest, [{last_from, Enum.max([to, last_to], Date)} | merged])
    else
      merge_spans(rest, [{from, to}, {last_from, last_to} | merged])
    end
  end

  @doc ~S(Human duration: `6 yrs`, `1 yr`, or `< 1 yr`.)
  @spec format_years(t()) :: String.t()
  def format_years(%__MODULE__{years: years}) do
    cond do
      years < 1.0 -> "< 1 yr"
      years < 1.75 -> "1 yr"
      true -> "#{round(years)} yrs"
    end
  end
end
