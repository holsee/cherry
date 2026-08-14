defmodule Cherry.Portfolio.Link do
  @moduledoc "A labelled URL: profile links and project links."

  @enforce_keys [:label, :url]
  defstruct [:label, :url]

  @type t :: %__MODULE__{label: String.t(), url: String.t()}
end
