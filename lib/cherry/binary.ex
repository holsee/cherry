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
    argv = binary_argv()
    code = Cherry.CLI.run(argv)

    # A blocking verb (serve) has a live supervision tree behind it;
    # halting here would tear the server down the moment the banner
    # prints. Anything else halts with the command's exit code.
    if code == 0 and blocking?(argv) do
      Process.sleep(:infinity)
    else
      System.halt(code)
    end
  end

  defp blocking?([verb | _rest]), do: Cherry.CLI.Registry.blocking?(verb)
  defp blocking?([]), do: false

  # Burrito hands user arguments to the VM as plain arguments
  # (System.argv/0 is empty inside a release).
  defp binary_argv do
    Enum.map(:init.get_plain_arguments(), &List.to_string/1)
  end
end
