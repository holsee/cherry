defmodule Cherry.Pipeline.Stages.Validate do
  @moduledoc """
  Validates loaded content against collection schemas.

  A pass-through until collections land (DO_NEXT slice 4); it exists now so
  the pipeline shape is the real architecture from the first build.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{} = build), do: {:ok, build}
end
