---
title: Deploying to GitHub Pages
description: gen.action writes the workflow; one Pages switch does the rest. Custom domains, project pages, and the base_path story.
---
# Deploying to GitHub Pages

Cherry generates its own deploy pipeline. You never write YAML unless you want to.

## Generate the workflow

```sh
cherry gen.action --json
```

```json
{
  "ok": true,
  "command": "gen.action",
  "data": {
    "path": ".github/workflows/pages.yml",
    "cname": "example.com",
    "branch": "main"
  }
}
```

The workflow builds your site with the published [Cherry build action](https://github.com/holsee/cherry/tree/develop/action) (toolchain setup, dependency caching, `cherry.build`, and `cherry.check --strict` in one `uses:` step), then uploads and deploys via GitHub's official Pages actions. It adds `.nojekyll`, and a `CNAME` when your site's `url` is a custom domain.

## One-time repo setup

**Settings → Pages → Build and deployment → Source → GitHub Actions.** That's the entire manual step. Every push to `main` now checks, builds, and ships.

## Custom domains

With `url: "https://example.com"` in `cherry.exs`, the workflow emits the `CNAME` file automatically. On the DNS side: a CNAME record from your domain to `<user>.github.io` (grey-cloud/DNS-only if you're on Cloudflare, so GitHub can issue the certificate), claim the domain in the repo's Pages settings, and enforce HTTPS once the cert lands.

> [!TIP]
> Also add the domain under your GitHub account's **Settings → Pages → Verified domains**. It's a one-time TXT record that prevents anyone claiming your domain if the Pages site is ever deleted.

## Project pages and base_path

Deploying to `https://user.github.io/myrepo/` means every URL needs the `/myrepo/` prefix. Set it once:

```elixir
# cherry.exs
url: "https://user.github.io",
base_path: "/myrepo"
```

Every emitted URL (pages, assets, feeds, canonical links, icons, nav) respects it. No template ever concatenates URL strings, so there's no class of half-prefixed bugs to chase. This is gate-tested on every commit at root *and* under a base path.

> [!NOTE]
> Sites with `search: "pagefind"` need Node available in the workflow (the post-build stage shells `npx pagefind`). The generated action handles toolchains for you; if you hand-roll a workflow, add `actions/setup-node` before the build.

Prefer Cloudflare? The same verb targets Workers static assets: the [Cloudflare guide](/guides/deploy-cloudflare/) is the walkthrough.
