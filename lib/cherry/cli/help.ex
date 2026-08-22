defmodule Cherry.CLI.Help do
  @moduledoc """
  Renders help text for the base CLI and for individual verbs.

  Everything here derives from `Cherry.CLI.Registry` and each command's
  `doc/0` — the same source that feeds the mix task docs and the agent
  skill — so help can never disagree with them.
  """

  alias Cherry.CLI.Registry

  @doc "The base help screen: usage, every verb with its summary, global flags."
  @spec base() :: String.t()
  def base do
    verbs = Registry.verbs()
    width = verbs |> Enum.map(&String.length/1) |> Enum.max()

    commands =
      Enum.map_join(verbs, "\n", fn verb ->
        {:ok, command} = Registry.fetch(verb)
        "  #{String.pad_trailing(verb, width)}  #{summary(command)}"
      end)

    """
    usage: cherry <command> [args] [flags]

    Commands:

    #{commands}

    Global flags (every command):

      --json     machine-readable envelope on stdout
      --verbose  extra detail for humans debugging

    Exit codes: 0 success, 1 the command ran and failed, 2 usage error.

    Run `cherry help <command>` or `cherry <command> --help` for one command.\
    """
  end

  @doc """
  Help for one verb: the command's doc text with usage shown in binary
  form (`cherry build`, not `mix cherry.build` — the two frontends are
  verb-for-verb identical, ADR 0006).
  """
  @spec verb(module()) :: String.t()
  def verb(command) do
    command.doc() |> String.replace("mix cherry.", "cherry ") |> String.trim_trailing()
  end

  @summary_width 72

  # The one-line summary is the first sentence of the doc text (the first
  # line alone can end mid-sentence when the opening paragraph wraps),
  # clamped so the command table stays a table: an overlong sentence falls
  # back to its pre-colon clause, then to a word-boundary cut. Trailing
  # periods go, git-style.
  defp summary(command) do
    command.doc()
    |> String.split("\n\n", parts: 2)
    |> hd()
    |> String.replace("\n", " ")
    |> first_sentence()
    |> clamp()
    |> String.trim_trailing(".")
  end

  defp first_sentence(text) do
    case String.split(text, ". ", parts: 2) do
      [whole] -> whole
      [first, _rest] -> first <> "."
    end
  end

  defp clamp(text) do
    cond do
      String.length(text) <= @summary_width -> text
      String.contains?(text, ": ") -> text |> String.split(": ", parts: 2) |> hd()
      true -> word_cut(text)
    end
  end

  defp word_cut(text) do
    text
    |> String.split(" ")
    |> Enum.reduce_while("", fn word, acc ->
      candidate = if acc == "", do: word, else: acc <> " " <> word

      if String.length(candidate) > @summary_width - 1,
        do: {:halt, acc <> "…"},
        else: {:cont, candidate}
    end)
  end
end
