defmodule Cherry.Pipeline.Stages.Post do
  @moduledoc """
  Post-build enhancements (DESIGN.md pipeline: "post — search index,
  fingerprints — optional").

  Today that is Pagefind: `search: "pagefind"` in `cherry.exs` shells
  out to index the emitted `_site/`. Opt-in, so core builds stay free
  of external tooling; `Cherry.check/1` skips this stage along with
  Emit because there is nothing on disk to index.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Site

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()} | {:error, String.t()}
  def run(%Build{site: %Site{search: nil}} = build), do: {:ok, build}

  def run(%Build{site: %Site{search: "pagefind"} = site} = build) do
    command = ~s(npx --yes pagefind --site "#{site.output}")

    case System.shell(command, stderr_to_stdout: true) do
      {_output, 0} ->
        {:ok, build}

      {output, code} ->
        {:error,
         "pagefind exited #{code} — search: \"pagefind\" needs Node.js and " <>
           "Pagefind available (npx pagefind).\n#{String.trim(output)}"}
    end
  end
end
