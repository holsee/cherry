defmodule Cherry.Commands.PortfolioScaffold do
  @moduledoc """
  Shared engine for the portfolio `gen.*` commands: title → slug →
  a frontmatter scaffold in the collection's directory, refusing to
  clobber existing entries.
  """

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Content.Slug

  @doc "Creates `dir/slug.md` with the scaffold's frontmatter."
  @spec run(Context.t(), String.t(), (String.t() -> String.t()), String.t()) ::
          {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [title | _rest], opts: opts}, dir, frontmatter, _usage) do
    source = Keyword.get(opts, :source, File.cwd!())
    slug = Slug.slugify(title)

    cond do
      slug == "" ->
        {:error, %Error{code: :bad_title, message: "title produces an empty slug", exit: 2}}

      not File.dir?(source) ->
        {:error, %Error{code: :no_site, message: "no such directory: #{source}"}}

      true ->
        write(source, dir, slug, frontmatter.(title))
    end
  end

  def run(%Context{}, _dir, _frontmatter, usage) do
    {:error, %Error{code: :usage, message: usage, exit: 2}}
  end

  @doc "The human line every scaffold command prints."
  @spec human(String.t()) :: String.t()
  def human(path) do
    "Created #{path} — fill in the frontmatter, then `cherry build` to see it."
  end

  defp write(source, dir, slug, content) do
    rel = Path.join(dir, "#{slug}.md")
    path = Path.join(source, rel)

    if File.exists?(path) do
      {:error, %Error{code: :exists, message: "#{rel} already exists"}}
    else
      File.mkdir_p!(Path.dirname(path))
      File.write!(path, content)
      {:ok, %{path: rel, slug: slug}}
    end
  end
end
