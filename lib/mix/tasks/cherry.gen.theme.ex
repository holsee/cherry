defmodule Mix.Tasks.Cherry.Gen.Theme do
  @shortdoc "Scaffolds a site-local theme from an official one"
  @moduledoc Cherry.Commands.GenTheme.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["gen.theme" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
