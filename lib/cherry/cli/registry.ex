defmodule Cherry.CLI.Registry do
  @moduledoc """
  Maps CLI verbs to their `Cherry.CLI.Command` modules.

  Deliberately a compile-time map: the verb surface is part of Cherry's
  public API and changes to it belong in code review, not runtime plugins.
  """

  @commands %{
    "version" => Cherry.Commands.Version
  }

  @doc "Looks up the command module for a verb."
  @spec fetch(String.t()) :: {:ok, module()} | :error
  def fetch(verb), do: Map.fetch(@commands, verb)

  @doc "All known verbs, sorted, for help and error output."
  @spec verbs() :: [String.t()]
  def verbs, do: @commands |> Map.keys() |> Enum.sort()
end
