defmodule Mix.Tasks.Cherry.Serve do
  @shortdoc "Builds and serves the site locally with live reload"
  @moduledoc Cherry.Commands.Serve.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: no_return()
  def run(argv) do
    case Cherry.CLI.run(["serve" | argv]) do
      # The one long-running task: the server is live, so hold the VM open.
      0 -> Process.sleep(:infinity)
      code -> exit({:shutdown, code})
    end
  end
end
