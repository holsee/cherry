defmodule Mix.Tasks.Cherry.Theme.Eject do
  @shortdoc "Copies a theme template into the site overlay with provenance"
  @moduledoc Cherry.Commands.ThemeEject.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["theme.eject" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
