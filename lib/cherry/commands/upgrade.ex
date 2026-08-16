defmodule Cherry.Commands.Upgrade do
  @doc_text """
  Upgrades the standalone `cherry` binary in place (ADR 0007).

  ## Usage

      cherry upgrade [--check] [--version vX.Y.Z] [--json]

  Resolves the latest stable GitHub release (or `--version` for a
  specific tag, prereleases included), downloads this platform's binary,
  verifies it against the release's `SHA256SUMS`, and swaps the running
  executable — rustup/deno style.

  `--check` only reports whether an upgrade is due and works anywhere;
  the swap itself needs the standalone binary. Mix users upgrade with
  `mix deps.update cherry` as ever.

  `--api-base URL` retargets the GitHub API for mirrors and tests.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Upgrade
  alias Cherry.Upgrade.Plan

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [check: :boolean, version: :string, api_base: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts}) do
    upgrade_opts =
      Enum.reject(
        [version: opts[:version], api_base: opts[:api_base]],
        fn {_key, value} -> is_nil(value) end
      )

    result =
      if Keyword.get(opts, :check, false) do
        check(upgrade_opts)
      else
        with {:ok, outcome} <- Upgrade.run(upgrade_opts), do: {:ok, run_data(outcome)}
      end

    with {:error, failure} <- result, do: {:error, translate(failure)}
  end

  # "Is there anything newer?" is a question, and "only prereleases exist"
  # is an answer to it — not a failure. Upgrading to a release that does
  # not exist still is.
  defp check(upgrade_opts) do
    case Upgrade.check(upgrade_opts) do
      {:ok, plan} ->
        {:ok, check_data(plan)}

      {:error, :no_stable_release} ->
        {:ok, %{current: Cherry.version(), target: nil, asset: nil, status: "no_stable_release"}}

      {:error, failure} ->
        {:error, failure}
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{status: "up_to_date", current: current}) do
    "cherry #{current} is up to date"
  end

  def human(%{status: "no_stable_release", current: current}) do
    "cherry #{current} — no stable release published yet; " <>
      "pass --version vX.Y.Z-rc.N to target a prerelease"
  end

  def human(%{status: "outdated", current: current, target: target}) do
    "cherry #{current} → #{target} available — run `cherry upgrade`"
  end

  def human(%{status: "upgraded", current: current, target: target} = data) do
    note =
      case data.retired do
        nil -> ""
        path -> "\nprevious binary left at #{path} (locked while running; safe to delete)"
      end

    "upgraded cherry #{current} → #{target}#{note}"
  end

  defp check_data(%Plan{} = plan) do
    %{
      current: plan.current,
      target: plan.release.tag,
      asset: plan.asset,
      status: Atom.to_string(plan.status)
    }
  end

  defp run_data(%{plan: plan, swapped?: swapped?, retired: retired, path: path}) do
    %{
      current: plan.current,
      target: plan.release.tag,
      asset: plan.asset,
      status: if(swapped?, do: "upgraded", else: "up_to_date"),
      path: path,
      retired: retired
    }
  end

  defp translate(:not_binary) do
    %Error{
      code: :not_binary,
      message:
        "cherry upgrade swaps the standalone binary; under mix, upgrade with " <>
          "`mix deps.update cherry` (or pass --check to compare versions)"
    }
  end

  defp translate(:no_stable_release) do
    %Error{
      code: :no_stable_release,
      message:
        "no stable release published yet — pass --version vX.Y.Z-rc.N to target a prerelease"
    }
  end

  defp translate({:release_not_found, tag}) do
    %Error{code: :release_not_found, message: "no release tagged #{tag}", details: %{tag: tag}}
  end

  defp translate({:asset_missing, name, tag}) do
    %Error{
      code: :asset_missing,
      message: "release #{tag} has no asset #{name} for this platform",
      details: %{asset: name, tag: tag}
    }
  end

  defp translate({:checksum_missing, name}) do
    %Error{
      code: :checksum_missing,
      message: "SHA256SUMS carries no entry for #{name} — refusing to install",
      details: %{asset: name}
    }
  end

  defp translate({:checksum_mismatch, name}) do
    %Error{
      code: :checksum_mismatch,
      message: "downloaded #{name} does not match SHA256SUMS — refusing to install",
      details: %{asset: name}
    }
  end

  defp translate({:http, url, reason}) do
    %Error{
      code: :http_error,
      message: "request to #{url} failed: #{inspect(reason)}",
      details: %{url: url}
    }
  end
end
