defmodule Cherry.Theme.Drift do
  @moduledoc """
  Managed drift (DESIGN.md, "the piece nobody ships"): because
  `theme.eject` recorded provenance, a theme upgrade is a mechanical
  three-way comparison — the base you ejected from, the installed
  upstream, and your copy.

  | status | meaning |
  |---|---|
  | `:current` | upstream unchanged since eject — nothing to do |
  | `:auto_updatable` | upstream moved, you didn't touch it — safe to re-eject |
  | `:conflict` | both moved — a human (or agent) resolves |
  | `:untracked` | no provenance header — a hand copy we cannot manage |
  """

  alias Cherry.Site
  alias Cherry.Theme
  alias Cherry.Theme.{Provenance, Resolver}

  defmodule Entry do
    @moduledoc "One overlay's drift status against the installed theme."

    @enforce_keys [:template, :overlay, :status]
    defstruct [:template, :overlay, :status]

    @type status :: :current | :auto_updatable | :conflict | :untracked

    @type t :: %__MODULE__{
            template: atom(),
            overlay: Path.t(),
            status: status()
          }
  end

  @doc "Drift entries for every template this site overlays, manifest order."
  @spec entries(Site.t(), Theme.t()) :: [Entry.t()]
  def entries(%Site{} = site, %Theme{} = theme) do
    for spec <- theme.templates,
        overlay = Resolver.overlay_path(site, theme, spec.name),
        not is_nil(overlay),
        File.exists?(overlay) do
      %Entry{template: spec.name, overlay: overlay, status: status(overlay, theme, spec.name)}
    end
  end

  @doc """
  Re-ejects an `:auto_updatable` overlay from the installed theme,
  stamping fresh provenance. Refuses any other status — a conflict or
  hand copy is never silently overwritten.
  """
  @spec update(Entry.t(), Theme.t()) :: :ok | {:error, String.t()}
  def update(%Entry{status: :auto_updatable} = entry, %Theme{} = theme) do
    upstream = theme |> Theme.template_path(entry.template) |> File.read!()
    File.write!(entry.overlay, Provenance.stamp(upstream, theme.name, theme.version))
    :ok
  end

  def update(%Entry{} = entry, %Theme{}) do
    {:error, "#{entry.template} is #{entry.status}, not auto-updatable"}
  end

  defp status(overlay, theme, name) do
    overlay_content = File.read!(overlay)
    upstream = theme |> Theme.template_path(name) |> File.read!()

    case Provenance.read(overlay_content) do
      :untracked ->
        :untracked

      {:ok, %Provenance{sha256: recorded}} ->
        cond do
          Provenance.hash(upstream) == recorded ->
            :current

          overlay_content |> Provenance.strip() |> Provenance.hash() == recorded ->
            :auto_updatable

          true ->
            :conflict
        end
    end
  end
end
