defmodule Mix.Tasks.Cherry.Theme.Which do
  @shortdoc "Prints a template's three-level resolution chain"
  @moduledoc Cherry.Commands.ThemeWhich.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["theme.which" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
