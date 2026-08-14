defmodule Cherry.Upgrade.Release do
  @moduledoc """
  A published Cherry release as the GitHub Releases API describes it:
  the tag, whether it is a prerelease, and a name → download-URL map of
  its assets (binaries plus `SHA256SUMS`).
  """

  @enforce_keys [:tag, :version, :prerelease?, :assets]
  defstruct tag: nil, version: nil, prerelease?: false, assets: %{}

  @type t :: %__MODULE__{
          tag: String.t(),
          version: String.t(),
          prerelease?: boolean(),
          assets: %{String.t() => String.t()}
        }

  @doc "Builds a Release from a decoded GitHub Releases API response."
  @spec from_api(map()) :: t()
  def from_api(%{"tag_name" => tag} = payload) do
    assets =
      payload
      |> Map.get("assets", [])
      |> Map.new(fn asset -> {asset["name"], asset["browser_download_url"]} end)

    %__MODULE__{
      tag: tag,
      version: String.trim_leading(tag, "v"),
      prerelease?: Map.get(payload, "prerelease", false),
      assets: assets
    }
  end
end
