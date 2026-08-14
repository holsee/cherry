defmodule Cherry.Theme.NavItem do
  @moduledoc """
  One entry in the site's header navigation.

  The layout template renders whatever list it is given; the Layout
  stage decides what exists (Blog always; Portfolio when the site has
  one), so themes never guess at site structure.
  """

  @enforce_keys [:label, :href]
  defstruct [:label, :href]

  @type t :: %__MODULE__{label: String.t(), href: String.t()}
end
