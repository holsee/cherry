defmodule Cherry.Portfolio.CV do
  @moduledoc """
  The `cv:` curation block on a portfolio entry (DESIGN.md §4): whether
  the entry appears on the CV, how prominently, and with which punchy
  bullets — while the markdown body stays the long-form story.
  """

  defstruct include: true, weight: 0, highlights: []

  @type t :: %__MODULE__{
          include: boolean(),
          weight: integer(),
          highlights: [String.t()]
        }
end
