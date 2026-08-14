defmodule Mix.Tasks.Cherry.Version do
  @shortdoc "Prints the Cherry version"
  @moduledoc Cherry.Commands.Version.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["version" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
