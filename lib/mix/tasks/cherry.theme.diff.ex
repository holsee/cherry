defmodule Mix.Tasks.Cherry.Theme.Diff do
  @shortdoc "Reports drift between theme overlays and the installed theme"
  @moduledoc Cherry.Commands.ThemeDiff.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["theme.diff" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
