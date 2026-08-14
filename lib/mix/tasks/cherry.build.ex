defmodule Mix.Tasks.Cherry.Build do
  @shortdoc "Builds the site into _site/"
  @moduledoc Cherry.Commands.Build.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["build" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
