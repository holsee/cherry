defmodule Mix.Tasks.Cherry.Gen.Action do
  @shortdoc "Generates a deploy pipeline (GitHub Pages or Cloudflare)"
  @moduledoc Cherry.Commands.GenAction.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["gen.action" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
