defmodule Cherry.Test.FakeReleaseServer do
  @moduledoc """
  A local stand-in for the GitHub Releases API: serves
  `/repos/holsee/cherry/releases/latest`, `/releases/tags/:tag`, and the
  release assets themselves from an in-memory description, so upgrade
  tests never touch the network.

  Mirrors GitHub's behavior that `releases/latest` returns 404 when the
  only release is a prerelease.
  """

  @behaviour Plug

  import Plug.Conn

  @type release :: %{tag: String.t(), prerelease: boolean(), assets: %{String.t() => binary()}}

  @doc "Starts the server on an ephemeral port; returns `{:ok, pid, port}`."
  @spec start(release()) :: {:ok, pid(), :inet.port_number()}
  def start(release) do
    {:ok, pid} =
      Bandit.start_link(plug: {__MODULE__, release}, port: 0, ip: :loopback, startup_log: false)

    {:ok, {_ip, port}} = ThousandIsland.listener_info(pid)
    {:ok, pid, port}
  end

  @doc "A sha256sum(1)-format SHA256SUMS body covering the given assets."
  @spec sha256sums(%{String.t() => binary()}) :: String.t()
  def sha256sums(assets) do
    Enum.map_join(assets, "", fn {name, bytes} ->
      Base.encode16(:crypto.hash(:sha256, bytes), case: :lower) <> "  " <> name <> "\n"
    end)
  end

  @impl Plug
  def init(release), do: release

  @impl Plug
  def call(conn, release) do
    case {conn.method, conn.path_info} do
      {"GET", ["repos", "holsee", "cherry", "releases", "latest"]} ->
        if release.prerelease,
          do: send_resp(conn, 404, "{}"),
          else: json(conn, release_payload(conn, release))

      {"GET", ["repos", "holsee", "cherry", "releases", "tags", tag]} ->
        if tag == release.tag,
          do: json(conn, release_payload(conn, release)),
          else: send_resp(conn, 404, "{}")

      {"GET", ["dl", name]} ->
        case Map.fetch(release.assets, name) do
          {:ok, bytes} -> send_resp(conn, 200, bytes)
          :error -> send_resp(conn, 404, "no such asset")
        end

      _other ->
        send_resp(conn, 404, "not found")
    end
  end

  defp release_payload(conn, release) do
    %{
      tag_name: release.tag,
      prerelease: release.prerelease,
      assets:
        Enum.map(release.assets, fn {name, _bytes} ->
          %{
            name: name,
            browser_download_url: "http://#{conn.host}:#{conn.port}/dl/#{name}"
          }
        end)
    }
  end

  defp json(conn, payload) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, JSON.encode!(payload))
  end
end
