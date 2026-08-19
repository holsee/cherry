defmodule Cherry.Commands.New do
  @doc_text """
  Scaffolds a new Cherry site: content directories, config, a first
  post, `AGENTS.md` documenting the agent workflow, and a `.claude`
  publish skill.

  ## Usage

      cherry new PATH [--json]

  This is the standalone binary's front door — the scaffold speaks
  `cherry <verb>` and carries no mix project. Elixir-toolchain users
  scaffold with the `cherry_new` archive instead (`mix cherry.new`),
  which writes the same site plus `mix.exs` and `config/config.exs`;
  for that reason this verb deliberately has no `mix cherry.new` twin
  in core — the archive owns that name.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}

  @doc "The single-sourced doc text, reused for `cherry help`."
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: [today: :string]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [path | _rest], opts: opts}) do
    title = path |> Path.expand() |> Path.basename() |> humanize()
    today = opts |> Keyword.get(:today) |> parse_today()

    cond do
      title == "" ->
        {:error,
         %Error{
           code: :bad_name,
           message: "cannot derive a site title from #{inspect(path)}",
           exit: 2
         }}

      File.exists?(path) and File.ls!(path) != [] ->
        {:error,
         %Error{
           code: :already_exists,
           message: "#{path} already exists and is not empty",
           exit: 2
         }}

      true ->
        files = files(title, today)

        Enum.each(files, fn {rel, content} ->
          target = Path.join(path, rel)
          File.mkdir_p!(Path.dirname(target))
          File.write!(target, content)
        end)

        {:ok, %{path: path, title: title, files: Enum.map(files, &elem(&1, 0))}}
    end
  end

  def run(%Context{}) do
    {:error, %Error{code: :usage, message: "usage: cherry new PATH", exit: 2}}
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{path: path, files: files}) do
    created = Enum.map(files, &"* creating #{&1}")

    next = """

    Your orchard is planted at #{path}. Next:

        cd #{path}
        cherry serve          # live-reloading dev server
        cherry check          # the verifier agents build against
        cherry gen.action     # GitHub Pages deploy workflow

    AGENTS.md documents the whole workflow — point your agent at it.
    """

    Enum.join(created, "\n") <> "\n" <> next
  end

  defp humanize(base) do
    base
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, " ")
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp parse_today(nil), do: Date.utc_today()
  defp parse_today(value), do: Date.from_iso8601!(value)

  defp files(title, today) do
    [
      {"cherry.exs", cherry_exs(title)},
      {".gitignore", "/_site/\n"},
      {"README.md", readme(title)},
      {"AGENTS.md", agents_md(title)},
      {".claude/skills/publish/SKILL.md", publish_skill()},
      {"content/pages/index.md", index_page(title)},
      {"content/pages/about.md", about_page(title)},
      {"content/posts/#{Date.to_iso8601(today)}-hello-cherry.md", first_post()},
      {"static/images/.gitkeep", ""}
    ]
  end

  defp cherry_exs(title) do
    """
    # Site configuration — every key is documented in Cherry's Site schema.
    [
      title: #{inspect(title)},
      # Set this to the site's real URL before deploying: canonical links,
      # feeds, and sitemap all derive from it.
      url: "https://example.com",
      description: "A site grown with Cherry."
    ]
    """
  end

  defp readme(title) do
    """
    # #{title}

    A static site built with [Cherry](https://github.com/holsee/cherry).

    | command | purpose |
    |---|---|
    | `cherry serve` | dev server with live reload |
    | `cherry gen.post "Title"` | new draft post |
    | `cherry publish SLUG` | draft → dated, published post |
    | `cherry build` | full build → `_site/` |
    | `cherry check` | verifier: links, metadata, feeds |

    Agents: start with `AGENTS.md`.
    """
  end

  defp agents_md(title) do
    """
    # AGENTS.md — operating #{title}

    This is a Cherry static site. Every command supports `--json` (machine
    envelopes) and meaningful exit codes (0 ok, 1 failed, 2 usage).

    ## The loop

    1. **Learn the schema first**: `cherry schema posts --json` says
       exactly what valid frontmatter looks like before you write a file.
    2. **Draft**: `cherry gen.post "Title" --json` → returns the path.
       Write the body in GitHub-flavored markdown. Always fill
       `description:` — the checker warns without it.
    3. **Verify**: `cherry check --strict --json`. Structured
       diagnostics (`file`, `rule`, `message`, `severity`); fix and
       re-run until clean. Nothing is written to disk by check.
    4. **Publish**: `cherry publish path/to/draft.md --json`
       re-dates the file and removes the draft flag.
    5. **Build**: `cherry build` → `_site/`. Deterministic: same
       inputs, same bytes.

    ## Rules

    - Never edit `_site/` — it is generated output.
    - Frontmatter is schema-validated; `cherry schema COLLECTION`
      lists every field.
    - Posts live at `content/posts/YYYY-MM-DD-slug.md`; the filename is
      the date and slug.
    - Theme customization is a ladder: config → tokens → `theme.eject`
      (records provenance) → `cherry theme.diff` keeps ejected
      copies upgradeable. Never hand-copy templates.
    - The published site carries a machine surface: `/llms.txt`, an
      `index.md` mirror beside every page, `feed.json` — read those
      instead of scraping HTML.

    ## Deploy

    `cherry gen.action` writes the GitHub Pages workflow; pushes to
    the default branch then build and deploy automatically.
    """
  end

  defp publish_skill do
    """
    ---
    name: publish
    description: Draft, verify, and publish a blog post on this Cherry site
    ---

    Publish a post end to end:

    1. `cherry gen.post "TITLE" --json` — note the returned path.
    2. Write the post body; fill `description:` in the frontmatter.
    3. `cherry check --strict --json` — fix every diagnostic until
       the run is clean.
    4. `cherry publish PATH --json` — the draft becomes a dated post.
    5. `cherry build` and confirm the new page exists under `_site/`.
    6. Commit the new post file (never `_site/`).
    """
  end

  defp index_page(title) do
    """
    ---
    title: Home
    description: #{title}, grown with Cherry.
    ---
    # #{title}

    Fresh from `cherry new`. Edit `content/pages/index.md` to make
    this page yours.
    """
  end

  defp about_page(title) do
    """
    ---
    title: About
    description: What #{title} is about.
    ---
    ## About

    Pages are freeform markdown; `about.md` becomes `/about/`.
    """
  end

  defp first_post do
    """
    ---
    title: Hello, Cherry
    description: The first post in a freshly planted orchard.
    tags:
      - meta
    ---
    This site is generated by [Cherry](https://github.com/holsee/cherry).

    Draft the next post with `cherry gen.post "Title"` — it arrives
    as a draft, invisible until `cherry publish`.
    """
  end
end
