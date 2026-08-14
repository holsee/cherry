defmodule Mix.Tasks.Cherry.Gen.Project do
  @shortdoc "Creates a new portfolio project entry"
  @moduledoc Cherry.Commands.GenProject.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["gen.project" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
