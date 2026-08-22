defmodule Cherry.Commands.GenPost do
  @doc_text """
  Creates a new draft post with valid frontmatter.

  ## Usage

      mix cherry.gen.post "Post title" [--source DIR] [--json]

  The file lands in `content/posts/` as `YYYY-MM-DD-slug.md` (today's date,
  slug derived from the title) with `draft: true`. Publishing later re-dates
  it (`mix cherry.publish`). With `--json`, the envelope carries the path —
  agents: write your content into that file, then `cherry build --drafts`
  to preview.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Content.Slug

  @impl Cherry.CLI.Command
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, today: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [title | _rest], opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    today = parse_today(opts)
    slug = Slug.slugify(title)

    cond do
      slug == "" ->
        {:error, %Error{code: :bad_title, message: "title produces an empty slug", exit: 2}}

      not File.dir?(source) ->
        {:error, %Error{code: :no_site, message: "no such directory: #{source}"}}

      true ->
        write_draft(source, today, slug, title)
    end
  end

  def run(%Context{}) do
    {:error, %Error{code: :usage, message: ~s(usage: cherry gen.post "Post title"), exit: 2}}
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{path: path}) do
    "Created draft #{path} — write away, then `cherry publish #{path}` when it's ready."
  end

  defp write_draft(source, today, slug, title) do
    rel = Path.join("content/posts", "#{Date.to_iso8601(today)}-#{slug}.md")
    path = Path.join(source, rel)

    if File.exists?(path) do
      {:error, %Error{code: :exists, message: "#{rel} already exists"}}
    else
      File.mkdir_p!(Path.dirname(path))

      File.write!(path, """
      ---
      title: #{inspect(title)}
      draft: true
      tags: []
      ---

      """)

      {:ok, %{path: rel, slug: slug, date: Date.to_iso8601(today)}}
    end
  end

  # `--today` exists for tests and agents replaying builds (ADR 0005 spirit:
  # time is an input). Humans never need it.
  defp parse_today(opts) do
    case Keyword.fetch(opts, :today) do
      {:ok, value} -> Date.from_iso8601!(value)
      :error -> Date.utc_today()
    end
  end
end
