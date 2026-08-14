defmodule Cherry.Binary do
  @moduledoc """
  Entrypoint for the standalone `cherry` binary (ADR 0007): argv →
  `Cherry.CLI.run/1` → exit code. The binary is a thin dispatcher over
  the same seam every mix task uses, so the two can never drift.

  Only the Burrito release boots this application — `mix.exs` sets the
  `mod:` entry solely when `CHERRY_RELEASE` is set at compile time, so
  sites embedding cherry as a dependency never start it.
  """

  use Application

  @impl Application
  @spec start(Application.start_type(), term()) :: {:ok, pid()}
  def start(_type, _args) do
    Task.start(&run_and_halt/0)
  end

  @spec run_and_halt() :: no_return()
  defp run_and_halt do
    code = Cherry.CLI.run(binary_argv())
    System.halt(code)
  end

  # Burrito hands user arguments to the VM as plain arguments
  # (System.argv/0 is empty inside a release).
  defp binary_argv do
    Enum.map(:init.get_plain_arguments(), &List.to_string/1)
  end
end
