defmodule Mix.Tasks.Cherry.Config do
  @shortdoc "Reads and writes cherry.exs"
  @moduledoc Cherry.Commands.Config.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["config" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
