defmodule Mix.Tasks.Cherry.New do
  @shortdoc "Scaffolds a new Cherry site"
  @moduledoc """
  Scaffolds a new Cherry site: content directories, config, a first
  post, `AGENTS.md` documenting the agent workflow, and a `.claude`
  publish skill.

  ## Usage

      mix cherry.new PATH [--cherry-path DIR]

  The directory name becomes the app name (`my_site` → `:my_site`).
  `--cherry-path` points the cherry dependency at a local checkout
  instead of GitHub (used by Cherry's own CI to dogfood the generator).

  ## Next steps

  The generator prints them: `mix deps.get`, `mix cherry.serve`,
  `mix cherry.gen.action` for the GitHub Pages deploy workflow.
  """

  use Mix.Task

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(argv) do
    {opts, args, invalid} = OptionParser.parse(argv, strict: [cherry_path: :string])

    cond do
      invalid != [] ->
        Mix.raise("invalid flags: #{Enum.map_join(invalid, ", ", &elem(&1, 0))}")

      args == [] ->
        Mix.raise("usage: mix cherry.new PATH [--cherry-path DIR]")

      true ->
        [path | _rest] = args
        generate(path, opts)
    end
  end

  defp generate(path, opts) do
    app = path |> Path.expand() |> Path.basename() |> to_app_name()
    title = humanize(app)

    if File.exists?(path) and File.ls!(path) != [] do
      Mix.raise("#{path} already exists and is not empty")
    end

    files = files(app, title, cherry_dep(opts))

    Enum.each(files, fn {rel, content} ->
      target = Path.join(path, rel)
      File.mkdir_p!(Path.dirname(target))
      File.write!(target, content)
      Mix.shell().info("* creating #{rel}")
    end)

    Mix.shell().info("""

    Your orchard is planted at #{path}. Next:

        cd #{path}
        mix deps.get
        mix cherry.serve          # live-reloading dev server
        mix cherry.check          # the verifier agents build against
        mix cherry.gen.action     # GitHub Pages deploy workflow

    AGENTS.md documents the whole workflow — point your agent at it.
    """)

    :ok
  end

  defp to_app_name(base) do
    app = base |> String.downcase() |> String.replace(~r/[^a-z0-9_]+/, "_") |> String.trim("_")

    if app =~ ~r/\A[a-z][a-z0-9_]*\z/ do
      app
    else
      Mix.raise("cannot derive an app name from #{inspect(base)} — use letters, digits, _")
    end
  end

  defp humanize(app) do
    app |> String.split("_") |> Enum.map_join(" ", &String.capitalize/1)
  end

  # Captured at compile time from the installer's own mix.exs; the
  # installer and cherry version in lockstep, so scaffolded sites depend
  # on the hex release that matches this installer. "~> X.Y.Z-rc.N"
  # also admits the eventual stable X.Y.Z.
  @cherry_version Mix.Project.config()[:version]

  defp cherry_dep(opts) do
    case Keyword.fetch(opts, :cherry_path) do
      {:ok, dir} -> ~s({:cherry, path: #{inspect(dir)}})
      :error -> ~s[{:cherry, "~> #{@cherry_version}"}]
    end
  end

  defp files(app, title, dep) do
    today = Date.to_iso8601(Date.utc_today())
    module = Macro.camelize(app)

    [
      {"mix.exs", mix_exs(app, module, dep)},
      {"config/config.exs", config_exs()},
      {"cherry.exs", cherry_exs(title)},
      {".gitignore", gitignore()},
      {"README.md", readme(title)},
      {"AGENTS.md", agents_md(title)},
      {".claude/skills/publish/SKILL.md", publish_skill()},
      {"content/pages/index.md", index_page(title)},
      {"content/pages/about.md", about_page(title)},
      {"content/posts/#{today}-hello-cherry.md", first_post()},
      {"static/images/.gitkeep", ""}
    ]
  end

  defp mix_exs(app, module, dep) do
    """
    defmodule #{module}.MixProject do
      use Mix.Project

      def project do
        [
          app: :#{app},
          version: "0.1.0",
          elixir: "~> 1.18",
          start_permanent: false,
          deps: deps()
        ]
      end

      def application do
        [extra_applications: []]
      end

      defp deps do
        [
          #{dep}
        ]
      end
    end
    """
  end

  defp config_exs do
    """
    import Config

    # Cherry highlights code with MDEx's Lumis engine. This selects the
    # right precompiled NIF and must be set before deps compile — keep it.
    config :mdex_native, syntax_highlighter: :lumis
    """
  end

  defp cherry_exs(title) do
    """
    # Site configuration — every key is documented in Cherry's Site schema.
    [
      title: #{inspect(title)},
      # Set this to the site's real URL before deploying: canonical links,
      # feeds, and sitemap all derive from it.
      url: "https://example.com",
      description: "A site grown with Cherry.",
      # Full-text search built in-process, no Node required. Swap for
      # "pagefind" if you prefer Pagefind, or delete the line for none.
      search: "cherry"
    ]
    """
  end

  defp gitignore do
    """
    /_site/
    /_build/
    /deps/
    """
  end

  defp readme(title) do
    """
    # #{title}

    A static site built with [Cherry](https://github.com/holsee/cherry).

    | task | purpose |
    |---|---|
    | `mix cherry.serve` | dev server with live reload |
    | `mix cherry.gen.post "Title"` | new draft post |
    | `mix cherry.publish PATH` | draft → dated, published post |
    | `mix cherry.build` | full build → `_site/` |
    | `mix cherry.check` | verifier: links, metadata, feeds |

    Agents: start with `AGENTS.md`.
    """
  end

  defp agents_md(title) do
    """
    # AGENTS.md — operating #{title}

    This is a Cherry static site. Every task supports `--json` (machine
    envelopes) and meaningful exit codes (0 ok, 1 failed, 2 usage).

    ## The loop

    1. **Learn the schema first**: `mix cherry.schema posts --json` says
       exactly what valid frontmatter looks like before you write a file.
    2. **Draft**: `mix cherry.gen.post "Title" --json` → returns the path.
       Write the body in GitHub-flavored markdown. Always fill
       `description:` — the checker warns without it.
    3. **Verify**: `mix cherry.check --strict --json`. Structured
       diagnostics (`file`, `rule`, `message`, `severity`); fix and
       re-run until clean. Nothing is written to disk by check.
    4. **Publish**: `mix cherry.publish path/to/draft.md --json`
       re-dates the file and removes the draft flag.
    5. **Build**: `mix cherry.build` → `_site/`. Deterministic: same
       inputs, same bytes.

    ## Rules

    - Never edit `_site/` — it is generated output.
    - Frontmatter is schema-validated; `mix cherry.schema COLLECTION`
      lists every field.
    - Posts live at `content/posts/YYYY-MM-DD-slug.md`; the filename is
      the date and slug.
    - Theme customization is a ladder: config → tokens → `theme.eject`
      (records provenance) → `mix cherry.theme.diff` keeps ejected
      copies upgradeable. Never hand-copy templates.
    - The published site carries a machine surface: `/llms.txt`, an
      `index.md` mirror beside every page, `feed.json` — read those
      instead of scraping HTML.

    ## Deploy

    `mix cherry.gen.action` writes the GitHub Pages workflow; pushes to
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

    1. `mix cherry.gen.post "TITLE" --json` — note the returned path.
    2. Write the post body; fill `description:` in the frontmatter.
    3. `mix cherry.check --strict --json` — fix every diagnostic until
       the run is clean.
    4. `mix cherry.publish PATH --json` — the draft becomes a dated post.
    5. `mix cherry.build` and confirm the new page exists under `_site/`.
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

    Fresh from `mix cherry.new`. Edit `content/pages/index.md` to make
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

    Draft the next post with `mix cherry.gen.post "Title"` — it arrives
    as a draft, invisible until `mix cherry.publish`.
    """
  end
end
