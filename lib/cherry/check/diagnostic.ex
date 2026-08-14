defmodule Cherry.Check.Diagnostic do
  @moduledoc """
  One structured finding from `cherry.check` (DESIGN.md §6): the file it
  came from, the rule that fired, what is wrong, and how bad it is.

  Structured because the check loop is an agent's verifier: build →
  check → fix diagnostics → repeat.
  """

  @enforce_keys [:file, :rule, :message, :severity]
  defstruct [:file, :line, :rule, :message, :severity]

  @type severity :: :error | :warning
  @type t :: %__MODULE__{
          file: String.t(),
          line: pos_integer() | nil,
          rule: String.t(),
          message: String.t(),
          severity: severity()
        }

  @doc "Errors first, then warnings; stable by file and rule within."
  @spec sort([t()]) :: [t()]
  def sort(diagnostics) do
    Enum.sort_by(diagnostics, &{severity_rank(&1.severity), &1.file, &1.rule, &1.message})
  end

  defp severity_rank(:error), do: 0
  defp severity_rank(:warning), do: 1
end
