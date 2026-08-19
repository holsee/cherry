defmodule Mix.Tasks.Cherry.Theme.Tokens do
  @shortdoc "Shows the theme's styling API: tokens, defaults, overrides"
  @moduledoc Cherry.Commands.ThemeTokens.doc()

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    case Cherry.CLI.run(["theme.tokens" | argv]) do
      0 -> :ok
      code -> exit({:shutdown, code})
    end
  end
end
