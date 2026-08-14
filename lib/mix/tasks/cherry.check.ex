defmodule Mix.Tasks.Cherry.Check do
  @shortdoc "Verifies the site: broken links, metadata, feed sanity"
  @moduledoc Cherry.Commands.Check.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["check" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
