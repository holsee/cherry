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

  # Deliberately synchronous: after boot, Burrito's wrapper hands the
  # plain arguments to `elixir start_cli`, whose Kernel.CLI would try
  # to run them as a script file. Running the command inside start/2
  # and halting first means that code path is never reached (this is
  # Burrito's documented entrypoint pattern).
  @dialyzer {:nowarn_function, start: 2}
  @impl Application
  @spec start(Application.start_type(), term()) :: no_return()
  def start(_type, _args) do
    code = Cherry.CLI.run(binary_argv())
    System.halt(code)
  end

  # Burrito hands user arguments to the VM as plain arguments
  # (System.argv/0 is empty inside a release).
  defp binary_argv do
    Enum.map(:init.get_plain_arguments(), &List.to_string/1)
  end
end
