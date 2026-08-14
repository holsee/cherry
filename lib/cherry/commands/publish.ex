defmodule Cherry.Commands.Publish do
  @doc_text """
  Publishes a draft: flips `draft: true` off and re-dates the post to today.

  ## Usage

      mix cherry.publish content/posts/2026-08-14-my-draft.md [--source DIR] [--json]

  The file is renamed to today's date (the filename is the source of truth
  for a post's date) and the `draft:` line is removed. With `--json`, the
  envelope carries the old and new paths.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}

  @doc "The single-sourced doc text, reused as the mix task's @moduledoc."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [source: :string, today: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [rel_path | _rest], opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    today = parse_today(opts)
    path = Path.join(source, rel_path)

    with :ok <- ensure_exists(path, rel_path),
         {:ok, slug} <- parse_slug(rel_path) do
      publish(source, path, slug, today)
    end
  end

  def run(%Context{}) do
    {:error,
     %Error{code: :usage, message: "usage: cherry publish content/posts/DRAFT.md", exit: 2}}
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{from: from, to: to}) do
    "Published: #{from} → #{to}"
  end

  defp ensure_exists(path, rel_path) do
    if File.exists?(path) do
      :ok
    else
      {:error, %Error{code: :not_found, message: "no such file: #{rel_path}"}}
    end
  end

  defp parse_slug(rel_path) do
    case Regex.run(~r/\A(\d{4}-\d{2}-\d{2})-(.+)\.md\z/, Path.basename(rel_path)) do
      [_, _date, slug] ->
        {:ok, slug}

      nil ->
        {:error,
         %Error{
           code: :bad_filename,
           message: "not a post file (expected YYYY-MM-DD-slug.md): #{rel_path}",
           exit: 2
         }}
    end
  end

  defp publish(source, path, slug, today) do
    content = File.read!(path)
    published = String.replace(content, ~r/^draft:.*\r?\n/m, "")

    new_rel = Path.join("content/posts", "#{Date.to_iso8601(today)}-#{slug}.md")
    new_path = Path.join(source, new_rel)

    File.write!(new_path, published)
    if Path.expand(new_path) != Path.expand(path), do: File.rm!(path)

    {:ok,
     %{
       from: to_url_path(Path.relative_to(path, source)),
       to: new_rel,
       date: Date.to_iso8601(today)
     }}
  end

  defp parse_today(opts) do
    case Keyword.fetch(opts, :today) do
      {:ok, value} -> Date.from_iso8601!(value)
      :error -> Date.utc_today()
    end
  end

  defp to_url_path(path), do: String.replace(path, "\\", "/")
end
