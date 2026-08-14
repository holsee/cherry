defmodule Mix.Tasks.Cherry.Schema do
  @shortdoc "Prints a collection's frontmatter schema"
  @moduledoc Cherry.Commands.Schema.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["schema" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
