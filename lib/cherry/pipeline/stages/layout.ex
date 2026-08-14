defmodule Cherry.Pipeline.Stages.Layout do
  @moduledoc """
  Wraps page content in theme layouts.

  A pass-through until the theme contract lands (DO_NEXT slice 5).
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{} = build), do: {:ok, build}
end
