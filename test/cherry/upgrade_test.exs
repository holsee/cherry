defmodule Cherry.UpgradeTest do
  # Not async: the full-flow tests set __BURRITO_BIN_PATH, which is
  # process-global environment.
  use ExUnit.Case

  alias Cherry.Test.FakeReleaseServer
  alias Cherry.Upgrade
  alias Cherry.Upgrade.Plan

  @moduletag :tmp_dir

  @new_binary "the new cherry binary bytes"

  describe "asset_name/2" do
    test "maps every release target" do
      assert Upgrade.asset_name({:win32, :nt}, "win32") == "cherry-windows-x86_64.exe"

      assert Upgrade.asset_name({:unix, :darwin}, "aarch64-apple-darwin24") ==
               "cherry-macos-aarch64"

      assert Upgrade.asset_name({:unix, :darwin}, "x86_64-apple-darwin22") ==
               "cherry-macos-x86_64"

      assert Upgrade.asset_name({:unix, :linux}, "x86_64-pc-linux-gnu") == "cherry-linux-x86_64"

      assert Upgrade.asset_name({:unix, :linux}, "aarch64-unknown-linux-gnu") ==
               "cherry-linux-aarch64"
    end

    test "normalizes Apple's arm64 spelling" do
      assert Upgrade.asset_name({:unix, :darwin}, "arm64-apple-darwin24") ==
               "cherry-macos-aarch64"
    end

    test "the running platform resolves to a known asset" do
      assert Upgrade.asset_name() in [
               "cherry-linux-x86_64",
               "cherry-linux-aarch64",
               "cherry-macos-x86_64",
               "cherry-macos-aarch64",
               "cherry-windows-x86_64.exe"
             ]
    end
  end

  describe "check/1" do
    test "reports outdated against a newer stable release" do
      port = serve(tag: "v9.9.9", prerelease: false)

      assert {:ok, %Plan{status: :outdated, current: current, release: release}} =
               Upgrade.check(api_base: api(port))

      assert current == Cherry.version()
      assert release.tag == "v9.9.9"
    end

    test "reports up to date when the release matches the running version" do
      port = serve(tag: "v" <> Cherry.version(), prerelease: false)

      assert {:ok, %Plan{status: :up_to_date}} = Upgrade.check(api_base: api(port))
    end

    test "latest 404s when only prereleases exist" do
      port = serve(tag: "v9.9.9", prerelease: true)

      assert {:error, :no_stable_release} = Upgrade.check(api_base: api(port))
    end

    test "the command answers rather than failing when only prereleases exist" do
      port = serve(tag: "v9.9.9", prerelease: true)

      context = %Cherry.CLI.Context{
        verb: "upgrade",
        args: [],
        opts: [check: true, api_base: api(port)]
      }

      # "nothing stable yet" is the answer to --check, not an error: an
      # agent asking whether an upgrade is due should not have to treat a
      # non-zero exit as normal.
      assert {:ok, %{status: "no_stable_release", target: nil} = data} =
               Cherry.Commands.Upgrade.run(context)

      assert data.current == Cherry.version()
      assert Cherry.Commands.Upgrade.human(data) =~ "no stable release published yet"
    end

    test "a prerelease is reachable by explicit tag" do
      port = serve(tag: "v9.9.9", prerelease: true)

      assert {:ok, %Plan{status: :outdated}} =
               Upgrade.check(api_base: api(port), version: "v9.9.9")
    end

    test "an unknown tag is release_not_found" do
      port = serve(tag: "v9.9.9", prerelease: false)

      assert {:error, {:release_not_found, "v1.2.3"}} =
               Upgrade.check(api_base: api(port), version: "v1.2.3")
    end
  end

  describe "run/1 — the full swap" do
    test "downloads, verifies, and replaces the binary", %{tmp_dir: tmp} do
      bin = fake_bin(tmp)
      port = serve_with_assets(tag: "v9.9.9")

      assert {:ok, %{swapped?: true, retired: nil, path: ^bin}} =
               Upgrade.run(api_base: api(port), bin_path: bin)

      assert File.read!(bin) == @new_binary
      refute File.exists?(bin <> ".new")
      refute File.exists?(bin <> ".old")
      assert_executable(bin)
    end

    test "up to date swaps nothing", %{tmp_dir: tmp} do
      bin = fake_bin(tmp)
      port = serve(tag: "v" <> Cherry.version(), prerelease: false)

      assert {:ok, %{swapped?: false}} = Upgrade.run(api_base: api(port), bin_path: bin)
      assert File.read!(bin) == "old binary"
    end

    test "a corrupted download is refused and the binary untouched", %{tmp_dir: tmp} do
      bin = fake_bin(tmp)
      asset = Upgrade.asset_name()

      assets = %{asset => @new_binary}
      sums = FakeReleaseServer.sha256sums(%{asset => "different bytes entirely"})

      {:ok, _pid, port} =
        FakeReleaseServer.start(%{
          tag: "v9.9.9",
          prerelease: false,
          assets: Map.put(assets, "SHA256SUMS", sums)
        })

      assert {:error, {:checksum_mismatch, ^asset}} =
               Upgrade.run(api_base: api(port), bin_path: bin)

      assert File.read!(bin) == "old binary"
    end

    test "a release without this platform's asset is refused", %{tmp_dir: tmp} do
      bin = fake_bin(tmp)
      port = serve(tag: "v9.9.9", prerelease: false)
      asset = Upgrade.asset_name()

      assert {:error, {:asset_missing, ^asset, "v9.9.9"}} =
               Upgrade.run(api_base: api(port), bin_path: bin)
    end

    test "outside the binary, upgrading refuses with guidance" do
      System.delete_env("__BURRITO_BIN_PATH")

      assert {:error, :not_binary} = Upgrade.run(api_base: "http://127.0.0.1:1")
    end

    test "the wrapper's env var locates the binary", %{tmp_dir: tmp} do
      bin = fake_bin(tmp)
      port = serve_with_assets(tag: "v9.9.9")

      System.put_env("__BURRITO_BIN_PATH", bin)
      on_exit(fn -> System.delete_env("__BURRITO_BIN_PATH") end)

      assert {:ok, %{swapped?: true, path: ^bin}} = Upgrade.run(api_base: api(port))
      assert File.read!(bin) == @new_binary
    end
  end

  # --- helpers --------------------------------------------------------------

  defp serve(tag: tag, prerelease: prerelease) do
    {:ok, _pid, port} =
      FakeReleaseServer.start(%{tag: tag, prerelease: prerelease, assets: %{}})

    port
  end

  defp serve_with_assets(tag: tag) do
    assets = %{Upgrade.asset_name() => @new_binary}

    {:ok, _pid, port} =
      FakeReleaseServer.start(%{
        tag: tag,
        prerelease: false,
        assets: Map.put(assets, "SHA256SUMS", FakeReleaseServer.sha256sums(assets))
      })

    port
  end

  defp api(port), do: "http://127.0.0.1:#{port}"

  defp fake_bin(tmp) do
    bin = Path.join(tmp, "cherry")
    File.write!(bin, "old binary")
    bin
  end

  defp assert_executable(bin) do
    case :os.type() do
      {:win32, _flavor} -> :ok
      {:unix, _flavor} -> assert Bitwise.band(File.stat!(bin).mode, 0o100) != 0
    end
  end
end
