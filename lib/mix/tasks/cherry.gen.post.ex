defmodule Mix.Tasks.Cherry.Gen.Post do
  @shortdoc "Creates a new draft post with valid frontmatter"
  @moduledoc Cherry.Commands.GenPost.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["gen.post" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
