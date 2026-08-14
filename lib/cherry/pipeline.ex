defmodule Cherry.Pipeline do
  @moduledoc """
  Runs a build token through an ordered list of stages.

  The default stage order is the architecture: load → validate → transform →
  layout → emit. A failing stage stops the run and reports which stage failed.
  """

  alias Cherry.Build
  alias Cherry.Pipeline.Stages

  @default_stages [
    Stages.Load,
    Stages.Validate,
    Stages.Transform,
    Stages.Layout,
    Stages.Emit
  ]

  @doc "The standard build pipeline, in order."
  @spec default_stages() :: [module()]
  def default_stages, do: @default_stages

  @doc "Threads the token through each stage, stopping at the first error."
  @spec run(Build.t(), [module()]) :: {:ok, Build.t()} | {:error, String.t()}
  def run(%Build{} = build, stages) do
    Enum.reduce_while(stages, {:ok, build}, fn stage, {:ok, acc} ->
      case stage.run(acc) do
        {:ok, %Build{} = next} -> {:cont, {:ok, next}}
        {:error, reason} -> {:halt, {:error, "#{stage_name(stage)}: #{reason}"}}
      end
    end)
  end

  defp stage_name(stage) do
    stage |> Module.split() |> List.last() |> String.downcase()
  end
end
