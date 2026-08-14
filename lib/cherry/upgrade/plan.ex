defmodule Cherry.Upgrade.Plan do
  @moduledoc """
  The answer to "what would `cherry upgrade` do right now?": the running
  version, the resolved target release, the platform asset that would be
  installed, and whether an upgrade is actually due.
  """

  alias Cherry.Upgrade.Release

  @enforce_keys [:current, :release, :asset, :status]
  defstruct current: nil, release: nil, asset: nil, status: :up_to_date

  @type t :: %__MODULE__{
          current: String.t(),
          release: Release.t(),
          asset: String.t(),
          status: :up_to_date | :outdated
        }
end
