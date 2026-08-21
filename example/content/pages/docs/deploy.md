---
title: Deploying
description: GitHub Pages, Cloudflare, custom domains, base_path, and what the generated pipelines actually do.
---
## Deploying

`_site/` is plain static files, so anything that serves files serves a Cherry site. There are two paved roads, GitHub Pages and Cloudflare, and each is one verb long.

### The generated workflow

```text
$ cherry gen.action
Wrote .github/workflows/pages.yml (CNAME: cherrybomb.dev) — enable it once under Settings → Pages → Source → GitHub Actions.
```

On every push to `main` (choose another with `--branch`), the workflow:

1. installs Cherry,
2. runs `cherry check --strict`, so a broken link or a missing description fails the push instead of reaching production,
3. runs `cherry build`,
4. uploads `_site/` and deploys it with GitHub's Pages actions.

It also writes `.nojekyll` (so nothing gets reprocessed) and, when your `url` is a custom domain, a `CNAME` file. One-time repo setup: Settings, then Pages, then Source: GitHub Actions.

:::note{title="Pagefind needs Node in CI"}
`search: "cherry"` needs nothing anywhere, which is why this site uses it. If you chose `search: "pagefind"`, the build shells out to `npx pagefind` at the end. GitHub's Ubuntu runners ship with Node, so the generated workflow works as-is; add a `setup-node` step if you want the version pinned and the npm cache warm.
:::

### Custom domains

Set `url` to the real domain and everything follows: canonical links, feeds, sitemap, the workflow's `CNAME`. Point DNS at GitHub Pages (an `A`/`ALIAS` set for an apex, a `CNAME` record for a subdomain), then turn on Enforce HTTPS in the repo's Pages settings once the certificate is issued. This site is deployed exactly this way; its config is [in the open](https://github.com/holsee/cherry/blob/main/example/cherry.exs).

### Project pages and base_path

Serving under `username.github.io/repo` means every URL needs a `/repo` prefix. That is one config key:

```elixir
base_path: "/repo"
```

Links, images, feed URLs, search assets, and [component](/docs/components/) `src`/`poster` paths are all rewritten. The verifier resolves links against the same rule, so a hardcoded absolute path that would break under the prefix is caught before it ships.

### Cloudflare

`cherry gen.action --host cloudflare` targets [Cloudflare Workers static assets](https://developers.cloudflare.com/workers/static-assets/) instead: it writes a `wrangler.jsonc` (no Worker script — just your `_site/` as assets, with `404.html` wired up) and a workflow that builds and ships with `wrangler deploy`. One-time setup is two repository secrets. Custom response headers and redirects are a `_headers` or `_redirects` file dropped into `static/`. The full walkthrough is the [Cloudflare guide](/guides/deploy-cloudflare/).

### Anywhere else

`cherry build && rsync -a _site/ server:/var/www/site/` is a complete deploy. Builds are [deterministic](/docs/pipeline/), so rsync transfers only what actually changed, and two machines building the same commit produce identical trees. Netlify and friends work the same way: point them at `cherry build` and `_site/`.
