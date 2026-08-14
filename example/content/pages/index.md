---
title: Home
description: Cherry is a static site generator for hackers. Typed content, deterministic builds, real theming, one binary.
---
<section class="hero">
<img class="hero-mark" src="/brand/cherrybomb-mark.webp" alt="CherryBomb: two cherries with a lit fuse and sunglasses" width="320" height="320">
<h1>A static site generator<br>for <em>hackers</em></h1>
<p class="hero-tagline">A modern take on Octopress: typed content, deterministic builds, themes that survive upgrades. One binary, fuse lit.</p>
<p class="hero-actions"><a class="button" href="/guides/quick-start/">Quick-start</a> <a class="button button-ghost" href="https://github.com/holsee/cherry">GitHub</a></p>
<div class="cmd"><span class="cmd-os">macOS / Linux</span><code>curl -fsSL https://cherrybomb.dev/install.sh | sh</code></div>
<div class="cmd"><span class="cmd-os">Windows</span><code>irm https://cherrybomb.dev/install.ps1 | iex</code></div>
</section>

<section class="loop">

## The loop

The whole workflow is four commands, and every one of them has a `--json` twin with stable exit codes. Pleasant to run by hand, trivial to script. Real output throughout.

### 1 · Scaffold

```sh
cherry gen.post "Growing season" --json
```

```json
{
  "ok": true,
  "command": "gen.post",
  "data": {
    "date": "2026-08-14",
    "path": "content/posts/2026-08-14-growing-season.md",
    "slug": "growing-season"
  }
}
```

One file, valid frontmatter, `draft: true`. The envelope hands back the path, so pipe it straight into your editor, a script, or whatever else does your writing.

### 2 · Verify

`cherry check` builds the whole site in memory, writes nothing, and returns structured diagnostics. Here it catches a link to a page that doesn't exist:

```sh
cherry check --strict --json
```

```json
{
  "ok": false,
  "command": "check",
  "error": {
    "code": "check_failed",
    "message": "Checked 12 page(s): 1 error(s), 0 warning(s).",
    "details": {
      "errors": 1,
      "diagnostics": [
        {
          "file": "content/pages/reading.md",
          "rule": "broken-link",
          "severity": "error",
          "message": "links to /guides/pruning/, which this build does not emit"
        }
      ]
    }
  }
}
```

The diagnostic names the file, the rule, and the problem. Fix it, run again, exit 0. That's the verifier loop: build, check, fix, repeat.

### 3 · Ship

```sh
cherry build
```

```text
Built 12 page(s), 2 asset(s) → _site
```

Same tree in, same bytes out: builds are deterministic, so your CI can prove nothing drifted. Push, and the GitHub Actions workflow from `cherry gen.action` deploys Pages. That's the entire pipeline.

</section>

<section class="wall">
<p class="wall-line"><strong>Typed content.</strong> Collections carry introspectable schemas (<code>cherry schema posts</code>), so frontmatter is a contract, not folklore.</p>
<p class="wall-line"><strong>Deterministic builds.</strong> Byte-identical output for identical input, gated in CI. Diffs mean something.</p>
<p class="wall-line"><strong>SEO you can't forget.</strong> Canonical, Open Graph, JSON-LD, Atom + JSON feeds, sitemap: default-on, framework-owned, in every theme.</p>
<p class="wall-line"><strong>Themes with a contract.</strong> Tokens are the styling API; ejected templates carry provenance, so upgrades merge instead of freezing.</p>
<p class="wall-line"><strong>Markdown all the way out.</strong> Every route ships its markdown beside the HTML, plus <a href="/llms.txt">/llms.txt</a>. Curl it, grep it.</p>
<p class="wall-line"><strong>One binary.</strong> No runtime to install. <code>cherry upgrade</code> swaps itself, checksum-verified, straight from the release.</p>
</section>

<section class="closing">

## Start here

The [quick-start](/guides/quick-start/) goes from install to a deployed site in fifteen minutes. The [guides](/guides/) cover the authoring loop, the verifier, themes, deploys, and scripting, including how the JSON interface pairs with the [shipped skill](/guides/agents/) if a coding agent helps run your site. This very site is Cherry's own dogfood: every page here is also [plain markdown](/index.md).

</section>
