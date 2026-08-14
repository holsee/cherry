defmodule Cherry.Collections do
  @moduledoc """
  The built-in content collections and their lookup.

  A collection is a directory, a schema, and routing rules (DESIGN.md §4).
  User-defined collections arrive in a later phase; the registry stays a
  compile-time map until then for the same reason the CLI registry does.
  """

  alias Cherry.Collections.{Pages, Portfolio, Posts}

  @collections %{
    "pages" => Pages,
    "posts" => Posts,
    "portfolio/positions" => Portfolio.Positions,
    "portfolio/projects" => Portfolio.Projects,
    "portfolio/talks" => Portfolio.Talks,
    "portfolio/oss" => Portfolio.Oss,
    "portfolio/education" => Portfolio.Education
  }

  @portfolio_names @collections
                   |> Map.keys()
                   |> Enum.filter(&String.starts_with?(&1, "portfolio/"))
                   |> Enum.sort()

  @doc "Looks up a collection module by name."
  @spec fetch(String.t()) :: {:ok, module()} | :error
  def fetch(name), do: Map.fetch(@collections, name)

  @doc "All collection names, sorted."
  @spec names() :: [String.t()]
  def names, do: @collections |> Map.keys() |> Enum.sort()

  @doc "All `{name, module}` pairs in load order (sorted by name)."
  @spec all() :: [{String.t(), module()}]
  def all, do: Enum.sort(@collections)

  @doc "The portfolio collection names, sorted."
  @spec portfolio_names() :: [String.t()]
  def portfolio_names, do: @portfolio_names
end
