defmodule Cherry.Build.Options do
  @moduledoc """
  Build-time selection options.

  `today` is an explicit input rather than a hidden clock read: future-post
  filtering is inherently time-dependent, so the time becomes part of the
  build's inputs and determinism (ADR 0005) is preserved — same inputs,
  same output.
  """

  @enforce_keys [:today]
  defstruct drafts?: false, future?: false, today: nil

  @type t :: %__MODULE__{
          drafts?: boolean(),
          future?: boolean(),
          today: Date.t()
        }

  @doc "Builds options from a keyword list; `today` defaults to UTC today."
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    %__MODULE__{
      drafts?: Keyword.get(opts, :drafts, false),
      future?: Keyword.get(opts, :future, false),
      today: Keyword.get(opts, :today, Date.utc_today())
    }
  end
end
