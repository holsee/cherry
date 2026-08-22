defmodule Cherry.CLI.Command do
  @moduledoc """
  Behaviour every Cherry command implements.

  A command is pure input → result: it receives a `Cherry.CLI.Context` and
  returns `{:ok, data}` or `{:error, %Cherry.CLI.Error{}}`. Rendering (human
  text vs `--json` envelope) belongs to `Cherry.CLI`, so commands stay
  testable without capturing IO.
  """

  alias Cherry.CLI.{Context, Error}

  @doc """
  The command's full doc text — the single source reused as the mix task's
  `@moduledoc` and rendered by `cherry help <verb>` and `cherry <verb> --help`.
  The first line doubles as the one-line summary on the base help screen.
  """
  @callback doc() :: String.t()

  @doc "Command-specific OptionParser switches, merged with the global ones."
  @callback switches() :: keyword()

  @doc "Executes the command."
  @callback run(Context.t()) :: {:ok, map()} | {:error, Error.t()}

  @doc "Renders the success data as the human-facing output line(s)."
  @callback human(map()) :: iodata()
end
