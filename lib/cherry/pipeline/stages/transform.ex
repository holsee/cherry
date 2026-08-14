defmodule Cherry.Pipeline.Stages.Transform do
  @moduledoc """
  Transforms page content — markdown rendering, highlighting, shortcodes.

  A pass-through until MDEx arrives with collections (DO_NEXT slice 4).
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{} = build), do: {:ok, build}
end
