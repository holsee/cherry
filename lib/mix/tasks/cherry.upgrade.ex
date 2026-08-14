defmodule Mix.Tasks.Cherry.Upgrade do
  @shortdoc "Upgrades the standalone cherry binary (or --check under mix)"
  @moduledoc Cherry.Commands.Upgrade.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["upgrade" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
