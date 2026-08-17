defmodule Cherry.Commands.Version do
  @doc_text """
  Prints the Cherry version.

  ## Usage

      mix cherry.version [--json]

  With `--json`, emits the standard envelope:

      {"ok":true,"command":"version","data":{"version":"...","revision":"..."}}

  `revision` is the git commit this build was compiled from, so a build
  from a branch is distinguishable from the release it was branched
  from. It is `null` when Cherry was compiled from a hex package rather
  than a checkout.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.Context

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: []

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()}
  def run(%Context{}), do: {:ok, %{version: Cherry.version(), revision: Cherry.revision()}}

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{version: version, revision: nil}), do: ["cherry ", version]

  def human(%{version: version, revision: revision}),
    do: ["cherry ", version, " (", revision, ")"]
end
