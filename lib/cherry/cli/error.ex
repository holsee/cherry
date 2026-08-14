defmodule Cherry.CLI.Error do
  @moduledoc """
  A structured command failure.

  `code` is the stable machine-readable identifier surfaced in `--json`
  envelopes; `message` is for humans; `exit` is the process exit code
  (1 = command failed, 2 = usage error — see `Cherry.CLI`).
  """

  @enforce_keys [:code, :message]
  defstruct code: nil, message: nil, details: %{}, exit: 1

  @type t :: %__MODULE__{
          code: atom(),
          message: String.t(),
          details: map(),
          exit: 1 | 2
        }
end
