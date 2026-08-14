defmodule Cherry.CLI.Context do
  @moduledoc """
  Parsed invocation state handed to every command.
  """

  @enforce_keys [:verb]
  defstruct verb: nil, args: [], opts: [], json?: false, verbose?: false

  @type t :: %__MODULE__{
          verb: String.t(),
          args: [String.t()],
          opts: keyword(),
          json?: boolean(),
          verbose?: boolean()
        }

  @doc "Builds a context from the parsed verb, positional args, and options."
  @spec new(String.t(), [String.t()], keyword()) :: t()
  def new(verb, args, opts) do
    %__MODULE__{
      verb: verb,
      args: args,
      opts: opts,
      json?: Keyword.get(opts, :json, false),
      verbose?: Keyword.get(opts, :verbose, false)
    }
  end
end
