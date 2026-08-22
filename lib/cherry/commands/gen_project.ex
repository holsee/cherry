defmodule Cherry.Commands.GenProject do
  @doc_text """
  Creates a new portfolio project entry with valid frontmatter.

  ## Usage

      mix cherry.gen.project "Project name" [--source DIR] [--json]

  The file lands in `content/portfolio/projects/` as `slug.md` with a
  `cv:` curation block ready to edit. With `--json`, the envelope
  carries the path — agents: fill in the frontmatter and body, then
  `cherry build` to see it on the timeline.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Commands.PortfolioScaffold

  @impl Cherry.CLI.Command
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{} = context) do
    PortfolioScaffold.run(context, "content/portfolio/projects", &frontmatter/1, usage())
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{path: path}), do: PortfolioScaffold.human(path)

  defp usage, do: ~s(usage: cherry gen.project "Project name")

  defp frontmatter(title) do
    """
    ---
    title: #{inspect(title)}
    status: active
    tags: []
    highlights: []
    cv:
      include: true
      weight: 0
    ---

    """
  end
end
