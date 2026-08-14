defmodule Cherry.Commands.Check do
  @doc_text """
  Verifies the site: builds it in memory and runs every check rule.

  ## Usage

      mix cherry.check [--source DIR] [--strict] [--drafts] [--future] [--json]

  Rules: broken internal links, missing descriptions, images without
  alt text, duplicate titles, Atom feed sanity. Errors exit 1;
  `--strict` promotes warnings to errors. Diagnostics are structured
  (`file`, `rule`, `message`, `severity`) — this is the agent's
  verifier loop: build → check → fix → repeat.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.Check.Diagnostic
  alias Cherry.CLI.{Context, Error}

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, strict: :boolean, drafts: :boolean, future: :boolean]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    strict? = Keyword.get(opts, :strict, false)

    case Cherry.check(Keyword.put(opts, :source, source)) do
      {:ok, build, diagnostics} ->
        report(build, diagnostics, strict?)

      {:error, message} ->
        {:error, %Error{code: :build_failed, message: message}}
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{diagnostics: [], pages: pages}) do
    "Checked #{pages} page(s): all clear."
  end

  def human(%{diagnostics: diagnostics, errors: errors, warnings: warnings, pages: pages}) do
    lines =
      Enum.map(diagnostics, fn diagnostic ->
        "  [#{diagnostic.severity}] #{diagnostic.file}: #{diagnostic.rule} — #{diagnostic.message}"
      end)

    summary = "Checked #{pages} page(s): #{errors} error(s), #{warnings} warning(s)."
    Enum.join([summary | lines], "\n")
  end

  defp report(build, diagnostics, strict?) do
    diagnostics = if strict?, do: promote(diagnostics), else: diagnostics
    errors = Enum.count(diagnostics, &(&1.severity == :error))
    warnings = Enum.count(diagnostics, &(&1.severity == :warning))

    data = %{
      pages: length(build.pages),
      errors: errors,
      warnings: warnings,
      diagnostics:
        Enum.map(diagnostics, &Map.take(&1, [:file, :line, :rule, :message, :severity]))
    }

    if errors > 0 do
      {:error,
       %Error{
         code: :check_failed,
         message: IO.iodata_to_binary(human(data)),
         details: data
       }}
    else
      {:ok, data}
    end
  end

  defp promote(diagnostics) do
    Enum.map(diagnostics, fn %Diagnostic{} = diagnostic ->
      %Diagnostic{diagnostic | severity: :error}
    end)
  end
end
