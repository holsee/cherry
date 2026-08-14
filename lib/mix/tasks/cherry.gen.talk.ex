defmodule Mix.Tasks.Cherry.Gen.Talk do
  @shortdoc "Creates a new portfolio talk entry"
  @moduledoc Cherry.Commands.GenTalk.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["gen.talk" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
