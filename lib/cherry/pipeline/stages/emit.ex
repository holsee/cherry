defmodule Cherry.Pipeline.Stages.Emit do
  @moduledoc """
  Writes the token to disk: pages as files, assets copied verbatim.

  Writes happen in sorted path order and contain only content-derived bytes,
  so the same token always produces a byte-identical `_site/` (ADR 0005).
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{site: site} = build) do
    File.mkdir_p!(site.output)

    build.pages
    |> Enum.sort_by(& &1.path)
    |> Enum.each(fn page -> write!(site.output, page.path, page.content) end)

    build.assets
    |> Enum.sort_by(& &1.path)
    |> Enum.each(fn asset ->
      destination = ensure_parent!(site.output, asset.path)
      File.cp!(asset.source, destination)
    end)

    {:ok, build}
  end

  defp write!(output, rel_path, content) do
    destination = ensure_parent!(output, rel_path)
    File.write!(destination, content)
  end

  defp ensure_parent!(output, rel_path) do
    destination = Path.join(output, rel_path)
    File.mkdir_p!(Path.dirname(destination))
    destination
  end
end
