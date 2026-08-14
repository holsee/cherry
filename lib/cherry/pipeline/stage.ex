defmodule Cherry.Pipeline.Stage do
  @moduledoc """
  Behaviour for a pipeline stage: token in, token out.

  Stages must be deterministic (ADR 0005) — no wall-clock time, no randomness,
  no map-ordering leaking into output. Site-local modules will implement this
  same behaviour to hook the pipeline.
  """

  alias Cherry.Build

  @doc "Transforms the build token."
  @callback run(Build.t()) :: {:ok, Build.t()} | {:error, String.t()}
end
