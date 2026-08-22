defmodule Cherry.CLI do
  @moduledoc """
  The single seam behind every Cherry frontend (ADR 0006).

  Mix tasks and the standalone binary are thin wrappers around `run/1` —
  verb for verb, flag for flag — so the two can never disagree.

  ## Exit codes

  | Code | Meaning |
  |---|---|
  | 0 | Success |
  | 1 | The command ran and failed |
  | 2 | Usage error: unknown verb or bad flags |

  ## Global flags

  Every command accepts `--json` (machine-readable envelope on stdout) and
  `--verbose` (extra detail for humans debugging).

  ## Help

  `cherry` bare, `cherry help`, and `cherry --help` print the command list;
  `cherry help <verb>` and `cherry <verb> --help` print one command's doc.
  Help always goes to stdout and exits 0.
  """

  alias Cherry.CLI.{Context, Error, Help, Registry}

  @global_switches [json: :boolean, verbose: :boolean]
  @help_flags ["--help", "-h"]

  @doc """
  Runs a Cherry command from raw argv and returns its exit code.

  The caller decides what to do with the code: mix tasks translate nonzero
  into `exit({:shutdown, code})`, the binary into `System.halt/1`.
  """
  @spec run([String.t()]) :: non_neg_integer()
  def run([]), do: base_help()
  def run(["help"]), do: base_help()
  def run(["help", verb | _rest]), do: verb_help(verb)
  def run([flag | _rest]) when flag in @help_flags, do: base_help()

  def run([verb | rest]) do
    case Registry.fetch(verb) do
      {:ok, command} -> run_command(command, verb, rest)
      :error -> render_unknown_verb(verb, rest)
    end
  end

  defp base_help do
    IO.puts(Help.base())
    0
  end

  defp verb_help(verb) do
    case Registry.fetch(verb) do
      {:ok, command} ->
        IO.puts(Help.verb(command))
        0

      :error ->
        render_unknown_verb(verb, [])
    end
  end

  # --help is intercepted before OptionParser (strict parsing would reject
  # it) and before dispatch, so `cherry serve --help` prints instead of
  # serving.
  defp run_command(command, verb, rest) do
    if Enum.any?(rest, &(&1 in @help_flags)) do
      IO.puts(Help.verb(command))
      0
    else
      parse_and_dispatch(command, verb, rest)
    end
  end

  defp parse_and_dispatch(command, verb, rest) do
    switches = Keyword.merge(@global_switches, command.switches())

    case OptionParser.parse(rest, strict: switches) do
      {opts, args, []} ->
        ctx = Context.new(verb, args, opts)
        dispatch(command, ctx)

      {_opts, _args, invalid} ->
        flags = Enum.map_join(invalid, ", ", fn {flag, _} -> flag end)
        json? = "--json" in rest
        render_error(usage_error("invalid flags: #{flags}"), verb, json?: json?)
    end
  end

  defp dispatch(command, ctx) do
    case command.run(ctx) do
      {:ok, data} -> render_ok(command, ctx, data)
      {:error, %Error{} = error} -> render_error(error, ctx.verb, json?: ctx.json?)
    end
  end

  defp render_ok(command, ctx, data) do
    if ctx.json? do
      IO.puts(JSON.encode!(%{ok: true, command: ctx.verb, data: data}))
    else
      IO.puts(command.human(data))
    end

    0
  end

  defp render_unknown_verb(verb, rest) do
    error =
      usage_error(
        "unknown command #{inspect(verb)} — available: #{Enum.join(Registry.verbs(), ", ")}"
      )

    render_error(error, verb, json?: "--json" in rest)
  end

  defp render_error(%Error{} = error, verb, json?: json?) do
    if json? do
      envelope = %{
        ok: false,
        command: verb,
        error: %{code: error.code, message: error.message, details: error.details}
      }

      IO.puts(JSON.encode!(envelope))
    else
      IO.puts(:stderr, "error: #{error.message}")
    end

    error.exit
  end

  defp usage_error(message), do: %Error{code: :usage, message: message, exit: 2}
end
