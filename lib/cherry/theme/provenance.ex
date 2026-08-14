defmodule Cherry.Theme.Provenance do
  @moduledoc """
  The lineage header written by `theme.eject` and read back to detect
  staleness (ADR 0004).

  Recording theme name, version, and content hash at eject time is what
  turns theme upgrades into a mechanical three-way comparison instead of
  Jekyll's silently frozen copies.
  """

  @header ~r/\A<%!-- cherry:eject theme=(\S+) version=(\S+) sha256=([0-9a-f]{64}) --%>\r?\n/

  @enforce_keys [:theme, :version, :sha256]
  defstruct [:theme, :version, :sha256]

  @type t :: %__MODULE__{
          theme: String.t(),
          version: String.t(),
          sha256: String.t()
        }

  @doc "Prepends a provenance header to ejected template content."
  @spec stamp(String.t(), String.t(), String.t()) :: String.t()
  def stamp(content, theme_name, theme_version) do
    "<%!-- cherry:eject theme=#{theme_name} version=#{theme_version} " <>
      "sha256=#{hash(content)} --%>\n" <> content
  end

  @doc "Reads the provenance header from an overlay file, if present."
  @spec read(String.t()) :: {:ok, t()} | :untracked
  def read(content) do
    case Regex.run(@header, content) do
      [_, theme, version, sha256] ->
        {:ok, %__MODULE__{theme: theme, version: version, sha256: sha256}}

      nil ->
        :untracked
    end
  end

  @doc "Content hash used in headers (lowercase hex SHA-256)."
  @spec hash(String.t()) :: String.t()
  def hash(content) do
    :sha256 |> :crypto.hash(content) |> Base.encode16(case: :lower)
  end

  @doc """
  Compares an overlay file against the currently installed theme template:
  `:fresh` (ejected from this exact content), `:stale` (upstream moved),
  or `:untracked` (no header — a hand copy).
  """
  @spec status(String.t(), String.t()) :: :fresh | :stale | :untracked
  def status(overlay_content, current_theme_content) do
    case read(overlay_content) do
      {:ok, %__MODULE__{sha256: recorded}} ->
        if recorded == hash(current_theme_content), do: :fresh, else: :stale

      :untracked ->
        :untracked
    end
  end
end
