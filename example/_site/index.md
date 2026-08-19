# Home

<section class="hero">
<img class="hero-mark" src="/brand/cherrybomb-mark.webp" alt="CherryBomb: two cherries with a lit fuse and sunglasses" width="320" height="320">
<h1>A static site generator<br>for <em>hackers</em></h1>
<p class="hero-tagline">A modern take on Octopress: typed content, deterministic builds, themes that survive upgrades. One binary, fuse lit.</p>
<p class="hero-actions"><a class="button" href="/guides/quick-start/">Quick-start</a> <a class="button button-ghost" href="https://github.com/holsee/cherry">GitHub</a></p>
<div class="cmd" data-copy><span class="cmd-os">macOS / Linux</span><code>curl -fsSL https://cherrybomb.dev/install.sh | sh</code></div>
<div class="cmd" data-copy><span class="cmd-os">Windows</span><code>irm https://cherrybomb.dev/install.ps1 | iex</code></div>
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

<section class="beyond">

## Not just a blog

The same content tree that builds your posts can carry your whole developer story. Portfolio collections (positions, projects, talks, open source, education) render a **timeline** at `/portfolio/`, **story pages** that cross-link everything sharing a tag, and a **`/cv`** shaped for employers: curated bullets, evidence-backed skills, a print stylesheet that produces a clean one-pager, and a machine-readable `cv.json` in JSON Resume format. All of it static, all of it typed, all of it checked by the same verifier as the blog.

</section>

<section class="checklist">

## The top ten

<ul class="checks">
<li><strong>One binary.</strong> No runtime to install; <code>cherry upgrade</code> swaps itself, checksum-verified.</li>
<li><strong>Typed content.</strong> Collections publish schemas; unknown frontmatter is a build error, not a mystery.</li>
<li><strong>Deterministic builds.</strong> Same tree in, same bytes out, gated in CI. Diffs mean something.</li>
<li><strong>A real verifier.</strong> <code>cherry check --strict</code> returns structured diagnostics, not vibes.</li>
<li><strong>Themes that survive upgrades.</strong> Tokens are the styling API; ejected templates carry provenance, so upgrades merge instead of freezing.</li>
<li><strong>Developer timeline + CV.</strong> Portfolio collections render a timeline, story pages, and a print-ready CV with JSON Resume output.</li>
<li><strong>SEO you can't forget.</strong> Canonical, Open Graph, JSON-LD, Atom + JSON feeds, sitemap: default-on in every theme.</li>
<li><strong>Markdown all the way out.</strong> Every route ships its markdown twin, plus <a href="/llms.txt">/llms.txt</a>. Curl it, grep it.</li>
<li><strong>AI-agent-friendly CLI.</strong> Every verb has a <code>--json</code> envelope, and the <a href="/guides/agents/">shipped skill</a> teaches an agent the whole loop.</li>
<li><strong>Batteries for shipping.</strong> Live-reload serve, opt-in Pagefind search, and a generated GitHub Pages workflow.</li>
</ul>

</section>

<section class="closing">

## Start here

The [quick-start](/guides/quick-start/) goes from install to a deployed site in fifteen minutes. The [guides](/guides/) cover the authoring loop, the verifier, themes, deploys, and scripting, including how the JSON interface pairs with the [shipped skill](/guides/agents/) if a coding agent helps run your site. This very site is Cherry's own dogfood: every page here is also [plain markdown](/index.md).

</section>
