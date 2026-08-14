defmodule Cherry.Pipeline.Stages.Machine do
  @moduledoc """
  Appends the machine surface (DESIGN.md §6): markdown mirrors and
  `llms.txt`.

  Runs after `Feeds` on purpose — the sitemap and Atom feed describe
  the human site, so mirrors must not leak into them.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Machine

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()}
  def run(%Build{} = build) do
    {:ok, %Build{build | pages: build.pages ++ Machine.pages(build)}}
  end
end
