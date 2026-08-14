defmodule Mix.Tasks.Cherry.Publish do
  @shortdoc "Publishes a draft: removes draft flag and re-dates the post"
  @moduledoc Cherry.Commands.Publish.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["publish" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
