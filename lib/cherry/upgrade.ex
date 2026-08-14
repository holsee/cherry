defmodule Cherry.Upgrade do
  @moduledoc """
  Self-update for the standalone binary (ADR 0007), rustup/deno style:
  resolve a release from the GitHub Releases API, download this
  platform's asset, verify it against the release's `SHA256SUMS`, and
  swap the running executable in place.

  Only the Burrito binary can swap itself — it knows its own path via
  `__BURRITO_BIN_PATH`. Everything up to the swap (the `check/1` plan)
  works anywhere, so mix users can still ask "am I current?".

  ## Options

    * `:version` — a tag like `"v0.1.0-rc.1"`; defaults to the latest
      stable release (`releases/latest` never returns prereleases).
    * `:api_base` — GitHub API base URL, for tests and mirrors.
    * `:fetch` — `url -> {:ok, body} | {:error, reason}` fetcher;
      defaults to `Cherry.Upgrade.HTTP.fetch/1`.
    * `:bin_path` — the executable to replace; defaults to
      `__BURRITO_BIN_PATH` (set by the Burrito wrapper).
  """

  alias Cherry.Upgrade.{HTTP, Plan, Release}

  @repo "holsee/cherry"
  @api_base "https://api.github.com"
  @checksums "SHA256SUMS"

  @type option ::
          {:version, String.t() | nil}
          | {:api_base, String.t()}
          | {:fetch, (String.t() -> {:ok, binary()} | {:error, term()})}
          | {:bin_path, Path.t() | nil}

  @typedoc "Why a check or upgrade could not proceed."
  @type failure ::
          :not_binary
          | :no_stable_release
          | {:release_not_found, String.t()}
          | {:asset_missing, String.t(), String.t()}
          | {:checksum_missing, String.t()}
          | {:checksum_mismatch, String.t()}
          | {:http, String.t(), term()}

  @doc "Resolves the target release and says whether an upgrade is due."
  @spec check([option()]) :: {:ok, Plan.t()} | {:error, failure()}
  def check(opts \\ []) do
    with {:ok, release} <- resolve_release(opts) do
      current = Cherry.version()

      {:ok,
       %Plan{
         current: current,
         release: release,
         asset: asset_name(),
         status: status(current, release.version)
       }}
    end
  end

  @doc """
  Runs the full upgrade: plan, download, verify, swap.

  Returns the plan plus `:swapped?` (false when already up to date) and
  `:retired` — the path of the previous executable when it could not be
  deleted (Windows keeps the running image locked; the leftover is
  harmless and reused by the next upgrade).
  """
  @spec run([option()]) ::
          {:ok, %{plan: Plan.t(), swapped?: boolean(), retired: Path.t() | nil, path: Path.t()}}
          | {:error, failure()}
  def run(opts \\ []) do
    with {:ok, bin_path} <- require_bin_path(opts),
         {:ok, %Plan{} = plan} <- check(opts) do
      case plan.status do
        :up_to_date -> {:ok, %{plan: plan, swapped?: false, retired: nil, path: bin_path}}
        :outdated -> download_and_swap(plan, bin_path, opts)
      end
    end
  end

  @doc "The release asset this platform installs (`cherry-linux-x86_64`, …)."
  @spec asset_name() :: String.t()
  def asset_name do
    asset_name(:os.type(), to_string(:erlang.system_info(:system_architecture)))
  end

  @doc "Pure mapping from OS/arch to the release asset name."
  @spec asset_name({:win32 | :unix, atom()}, String.t()) :: String.t()
  def asset_name({:win32, _flavor}, _arch), do: "cherry-windows-x86_64.exe"
  def asset_name({:unix, :darwin}, arch), do: "cherry-macos-#{normalize_arch(arch)}"
  def asset_name({:unix, _flavor}, arch), do: "cherry-linux-#{normalize_arch(arch)}"

  defp normalize_arch("aarch64" <> _rest), do: "aarch64"
  defp normalize_arch("arm64" <> _rest), do: "aarch64"
  defp normalize_arch(_arch), do: "x86_64"

  # --- release resolution ---------------------------------------------------

  defp resolve_release(opts) do
    api_base = Keyword.get(opts, :api_base, @api_base)
    fetch = Keyword.get(opts, :fetch, &HTTP.fetch/1)

    case Keyword.get(opts, :version) do
      nil -> fetch_release(fetch, "#{api_base}/repos/#{@repo}/releases/latest", :latest)
      tag -> fetch_release(fetch, "#{api_base}/repos/#{@repo}/releases/tags/#{tag}", tag)
    end
  end

  defp fetch_release(fetch, url, which) do
    case fetch.(url) do
      {:ok, body} -> {:ok, Release.from_api(JSON.decode!(body))}
      {:error, {:status, 404}} when which == :latest -> {:error, :no_stable_release}
      {:error, {:status, 404}} -> {:error, {:release_not_found, which}}
      {:error, reason} -> {:error, {:http, url, reason}}
    end
  end

  defp status(current, target) do
    with {:ok, current_version} <- Version.parse(current),
         {:ok, target_version} <- Version.parse(target),
         :eq <- Version.compare(current_version, target_version) do
      :up_to_date
    else
      _different -> :outdated
    end
  end

  # --- download, verify, swap ------------------------------------------------

  defp download_and_swap(%Plan{} = plan, bin_path, opts) do
    fetch = Keyword.get(opts, :fetch, &HTTP.fetch/1)

    with {:ok, binary} <- fetch_asset(fetch, plan.release, plan.asset),
         {:ok, sums} <- fetch_asset(fetch, plan.release, @checksums),
         :ok <- verify(binary, sums, plan.asset) do
      retired = swap(bin_path, binary)
      {:ok, %{plan: plan, swapped?: true, retired: retired, path: bin_path}}
    end
  end

  defp fetch_asset(fetch, %Release{} = release, name) do
    case Map.fetch(release.assets, name) do
      {:ok, url} ->
        case fetch.(url) do
          {:ok, body} -> {:ok, body}
          {:error, reason} -> {:error, {:http, url, reason}}
        end

      :error ->
        {:error, {:asset_missing, name, release.tag}}
    end
  end

  defp verify(binary, sums, asset) do
    actual = Base.encode16(:crypto.hash(:sha256, binary), case: :lower)

    case checksum_for(sums, asset) do
      nil -> {:error, {:checksum_missing, asset}}
      ^actual -> :ok
      _expected -> {:error, {:checksum_mismatch, asset}}
    end
  end

  # SHA256SUMS lines are `<hex><space><space-or-*><filename>` (sha256sum(1)).
  defp checksum_for(sums, asset) do
    sums
    |> String.split("\n", trim: true)
    |> Enum.find_value(fn line ->
      case Regex.run(~r/^([0-9a-f]{64})\s+\*?(.+)$/, String.trim(line)) do
        [_line, hex, ^asset] -> hex
        _other -> nil
      end
    end)
  end

  # Write beside the target, then two renames: the running executable can
  # always be renamed (even on Windows) though not overwritten, and rename
  # within one directory is atomic where the OS allows it.
  defp swap(bin_path, binary) do
    staged = bin_path <> ".new"
    retired = bin_path <> ".old"

    File.write!(staged, binary)
    _ = File.chmod(staged, 0o755)
    _ = File.rm(retired)
    File.rename!(bin_path, retired)
    File.rename!(staged, bin_path)

    case File.rm(retired) do
      :ok -> nil
      {:error, _locked} -> retired
    end
  end

  defp require_bin_path(opts) do
    case Keyword.get(opts, :bin_path) || System.get_env("__BURRITO_BIN_PATH") do
      nil -> {:error, :not_binary}
      path -> {:ok, path}
    end
  end
end
