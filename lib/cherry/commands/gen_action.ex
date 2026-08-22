defmodule Cherry.Commands.GenAction do
  @doc_text """
  Generates a deploy pipeline for this site.

  ## Usage

      mix cherry.gen.action [--host github|cloudflare] [--source DIR] [--branch NAME] [--name NAME] [--force] [--json]

  The default host, `github`, writes `.github/workflows/pages.yml`: build
  on push to `--branch` (default `main`), upload the site, deploy via
  GitHub's Pages actions. The workflow adds `.nojekyll`, and a `CNAME`
  when the site's `url` is a custom domain (skipped for `*.github.io` and
  subpath `base_path` sites). One-time repo setup: Settings → Pages →
  Source → GitHub Actions.

  `--host cloudflare` targets Cloudflare Workers static assets: writes
  `wrangler.jsonc` (Worker named by `--name`, default a slug of the site
  title) plus `.github/workflows/cloudflare.yml`, which builds the site
  and ships it with `wrangler deploy`. One-time repo setup: add
  `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` repository secrets.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Site

  @pages_workflow ".github/workflows/pages.yml"
  @cloudflare_workflow ".github/workflows/cloudflare.yml"
  @wrangler_config "wrangler.jsonc"

  @impl Cherry.CLI.Command
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches,
    do: [source: :string, branch: :string, host: :string, name: :string, force: :boolean]

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{opts: opts}) do
    source = Keyword.get(opts, :source, File.cwd!())
    branch = Keyword.get(opts, :branch, "main")

    with {:ok, host} <- parse_host(opts),
         {:ok, site} <- load_site(source) do
      generate(host, site, source, branch, opts)
    end
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{host: "cloudflare", path: path, config: config, name: name}) do
    [
      "Wrote #{config} (worker: #{name}) and #{path} — add the ",
      "CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID repository secrets once, ",
      "then every push deploys to #{name}.<account>.workers.dev."
    ]
  end

  def human(%{path: path, cname: cname}) do
    [
      "Wrote #{path}",
      if(cname, do: " (CNAME: #{cname})", else: ""),
      " — enable it once under Settings → Pages → Source → GitHub Actions."
    ]
  end

  defp generate("github", site, source, branch, opts) do
    path = Path.join(source, @pages_workflow)

    with :ok <- refuse_overwrite(path, @pages_workflow, opts) do
      cname = custom_domain(site)

      File.mkdir_p!(Path.dirname(path))
      File.write!(path, pages_workflow(branch, cname))

      {:ok, %{host: "github", path: @pages_workflow, branch: branch, cname: cname}}
    end
  end

  defp generate("cloudflare", site, source, branch, opts) do
    workflow_path = Path.join(source, @cloudflare_workflow)
    config_path = Path.join(source, @wrangler_config)
    name = Keyword.get_lazy(opts, :name, fn -> worker_name(site) end)

    with :ok <- refuse_overwrite(workflow_path, @cloudflare_workflow, opts),
         :ok <- refuse_overwrite(config_path, @wrangler_config, opts) do
      File.mkdir_p!(Path.dirname(workflow_path))
      File.write!(workflow_path, cloudflare_workflow(branch))
      File.write!(config_path, wrangler_config(name))

      {:ok,
       %{
         host: "cloudflare",
         path: @cloudflare_workflow,
         config: @wrangler_config,
         name: name,
         branch: branch
       }}
    end
  end

  defp parse_host(opts) do
    case Keyword.get(opts, :host, "github") do
      host when host in ["github", "cloudflare"] ->
        {:ok, host}

      other ->
        {:error,
         %Error{
           code: :usage,
           message: "unknown --host #{inspect(other)} — expected github or cloudflare",
           exit: 2
         }}
    end
  end

  defp load_site(source) do
    case Site.load(source) do
      {:ok, site} -> {:ok, site}
      {:error, message} -> {:error, %Error{code: :no_site, message: message}}
    end
  end

  defp refuse_overwrite(path, rel, opts) do
    if File.exists?(path) and not Keyword.get(opts, :force, false) do
      {:error, %Error{code: :exists, message: "#{rel} already exists (use --force)"}}
    else
      :ok
    end
  end

  # A CNAME only makes sense for an apex/subdomain site on a custom domain;
  # *.github.io and project-pages (subpath) sites never carry one.
  defp custom_domain(%Site{base_path: base_path}) when base_path != "/", do: nil

  defp custom_domain(%Site{url: url}) do
    case URI.parse(url).host do
      nil -> nil
      host -> if String.ends_with?(host, ".github.io"), do: nil, else: host
    end
  end

  # Worker names are lowercase DNS-ish labels; a slug of the site title is
  # the obvious default, with --name for anyone who wants control.
  defp worker_name(%Site{title: title}) do
    case title |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-") do
      "" -> "cherry-site"
      slug -> slug
    end
  end

  defp pages_workflow(branch, cname) do
    cname_step =
      if cname do
        "\n      - run: echo \"#{cname}\" > _site/CNAME"
      else
        ""
      end

    """
    # Generated by `mix cherry.gen.action` — regenerate with --force rather
    # than editing, or delete this header to take ownership.
    name: Deploy to GitHub Pages

    on:
      push:
        branches: [#{branch}]
      workflow_dispatch:

    permissions:
      contents: read
      pages: write
      id-token: write

    concurrency:
      group: pages
      cancel-in-progress: true

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v7

          # Toolchain setup, caching, build, and cherry.check in one step.
          - uses: holsee/cherry/action@#{action_ref()}

          - run: touch _site/.nojekyll#{cname_step}

          - uses: actions/upload-pages-artifact@v5
            with:
              path: _site

      deploy:
        needs: build
        runs-on: ubuntu-latest
        environment:
          name: github-pages
          url: ${{ steps.deployment.outputs.page_url }}
        steps:
          - id: deployment
            uses: actions/deploy-pages@v5
    """
  end

  defp cloudflare_workflow(branch) do
    """
    # Generated by `mix cherry.gen.action --host cloudflare` — regenerate with
    # --force rather than editing, or delete this header to take ownership.
    name: Deploy to Cloudflare

    on:
      push:
        branches: [#{branch}]
      workflow_dispatch:

    permissions:
      contents: read

    concurrency:
      group: cloudflare
      cancel-in-progress: true

    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v7

          # Toolchain setup, caching, build, and cherry.check in one step.
          - uses: holsee/cherry/action@#{action_ref()}

          # Ships _site as Workers static assets, per wrangler.jsonc.
          - uses: cloudflare/wrangler-action@v4
            with:
              apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
              accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
              command: deploy
    """
  end

  # A static-assets-only Worker: no main script, no html_handling override
  # (the auto-trailing-slash default matches Cherry's directory-index URLs),
  # and 404.html — which every build emits — as the not-found page.
  defp wrangler_config(name) do
    """
    // Generated by `mix cherry.gen.action --host cloudflare` — regenerate
    // with --force rather than editing, or delete this header to take
    // ownership.
    {
      "name": "#{name}",
      "compatibility_date": "#{Date.to_iso8601(Date.utc_today())}",
      "assets": {
        "directory": "./_site",
        "not_found_handling": "404-page"
      }
    }
    """
  end

  # The action ref tracks the running cherry version: every release tags
  # the repo and action/ ships inside it, so v<version> always resolves
  # for a released cherry. Sites get the action revision that shipped
  # with the cherry that generated their workflow.
  defp action_ref do
    "v" <> to_string(Application.spec(:cherry, :vsn))
  end
end
