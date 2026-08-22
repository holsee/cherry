defmodule Cherry.Commands.GenTalk do
  @doc_text """
  Creates a new portfolio talk entry with valid frontmatter.

  ## Usage

      mix cherry.gen.talk "Talk title" [--source DIR] [--today DATE] [--json]

  The file lands in `content/portfolio/talks/` as `slug.md`, dated
  today (override with `--today`, for replays). Fill in the event and
  links, then `cherry build` to see it on the timeline.
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
  def switches, do: [source: :string, today: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts} = context) do
    today = parse_today(opts)

    PortfolioScaffold.run(context, "content/portfolio/talks", &frontmatter(&1, today), usage())
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{path: path}), do: PortfolioScaffold.human(path)

  defp usage, do: ~s(usage: cherry gen.talk "Talk title")

  defp frontmatter(title, today) do
    """
    ---
    title: #{inspect(title)}
    event: ""
    date: #{Date.to_iso8601(today)}
    tags: []
    ---

    """
  end

  defp parse_today(opts) do
    case Keyword.fetch(opts, :today) do
      {:ok, value} -> Date.from_iso8601!(value)
      :error -> Date.utc_today()
    end
  end
end
