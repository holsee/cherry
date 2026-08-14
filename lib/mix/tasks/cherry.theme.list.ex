defmodule Mix.Tasks.Cherry.Theme.List do
  @shortdoc "Shows the active theme's templates, tokens, and overlays"
  @moduledoc Cherry.Commands.ThemeList.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["theme.list" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
