---
title: Home
description: Write markdown, get a whole website. Cherry is a one-binary static site generator that builds your blog, pages, and developer CV, and deploys them to GitHub Pages or Cloudflare.
---
<section class="hero">
<img class="hero-mark" src="/brand/cherrybomb-mark.webp" alt="CherryBomb: two cherries with a lit fuse and sunglasses" width="320" height="320">
<h1>A static site generator<br>for all the <em>hackers</em></h1>
<p class="hero-tagline">Write markdown files, get a whole website: a blog, your pages, and a developer portfolio with a print-ready CV. Cherry is the one binary that builds it, checks it, and deploys it to GitHub Pages or Cloudflare. No Node, no config safari. Fuse lit.</p>
<p class="hero-actions"><a class="button" href="/guides/quick-start/">Quick-start</a> <a class="button button-ghost" href="/docs/">Docs</a> <a class="button button-ghost" href="https://github.com/holsee/cherry">GitHub</a></p>
<div class="cmd" data-copy><span class="cmd-os">macOS / Linux</span><code>curl -fsSL https://cherrybomb.dev/install.sh | sh</code></div>
<div class="cmd" data-copy><span class="cmd-os">Windows</span><code>irm https://cherrybomb.dev/install.ps1 | iex</code></div>
</section>

<section class="checklist">

<ul class="checks">
<li><strong>One binary.</strong> No runtime to install; <code>cherry upgrade</code> swaps itself, checksum-verified. <code>cherry new</code> scaffolds a site in one command.</li>
<li><strong>Typed content.</strong> Collections publish schemas; unknown frontmatter is a build error, not a mystery.</li>
<li><strong>Deterministic builds.</strong> Same tree in, same bytes out, gated in CI. Diffs mean something.</li>
<li><strong>A real verifier.</strong> <code>cherry check --strict</code> returns structured diagnostics, not vibes.</li>
<li><strong>Themes that survive upgrades.</strong> Tokens are the styling API; ejected templates carry provenance, so upgrades merge instead of freezing.</li>
<li><strong>Light and dark as one value.</strong> Colour tokens are <code>light-dark()</code> pairs; the toggle flips <code>color-scheme</code> and print stays clean.</li>
<li><strong>Content components.</strong> Figures, privacy-preserving video facades, and callouts as directives; misuse is a diagnostic, never a broken build.</li>
<li><strong>Two template languages.</strong> EEx or HEEx, decided by file extension; HEEx brings escaping by default and Phoenix-style function components, inside a static binary.</li>
<li><strong>Developer timeline + CV.</strong> Portfolio collections render a timeline, story pages, and a print-ready CV with JSON Resume output.</li>
<li><strong>SEO you can't forget.</strong> Canonical, Open Graph, JSON-LD, Atom + JSON feeds, sitemap: default-on in every theme.</li>
<li><strong>Markdown all the way out.</strong> Every route ships its markdown twin, plus <a href="/llms.txt">/llms.txt</a>. Curl it, grep it.</li>
<li><strong>AI-agent-friendly CLI.</strong> Every verb has a <code>--json</code> envelope, and the <a href="/guides/agents/">shipped skill</a> teaches an agent the whole loop.</li>
</ul>

</section>

<section class="loop">

## One CLI to rule them all

Content is just files: a post is one markdown file in `content/posts/`, a page is one in `content/pages/`, and the filename gives the URL. Install the binary, then watch how far four commands go. Real output throughout, because this site is built by the same tool it describes.

### 0 · Let your agent cook

Prefer to delegate? Cherry ships a [skill](/guides/agents/) that teaches a coding agent every verb, the JSON envelopes, and the verify-fix loop. One command installs it (swap the agent flag for `github-copilot`, `cursor`, `codex`, and friends):

```sh
gh skill install holsee/cherry cherry --agent claude-code
```

Then steps 1 to 4 below are things you can simply ask for:

```text
Create a new cherry site for my blog and serve it locally.
```

```text
Scaffold my portfolio from my CV and this list of talks, then curate
which entries make the /cv/ page.
```

```text
Set up deploys to Cloudflare on every push to main.
```

```text
Draft a post from these meeting notes and run cherry check before
showing me anything.
```

And the loop does not stop at scaffolding:

```text
Migrate my old Jekyll posts into content/posts/ and fix whatever
cherry check flags.
```

```text
Change the accent colour to match my logo, in light and dark.
```

```text
Change the footer to link my Mastodon and my GitHub.
```

```text
Scaffold a theme called porcelain from the default theme and make it
mine: serif body, a muted sage accent as a light-dark pair, generous
whitespace. Keep every token the manifest declares, run cherry check,
and show me the home page and /cv/ in both light and dark before we
keep it.
```

```text
Add my three most recent conference talks to the portfolio with
links to the videos.
```

The skill carries the error-recovery playbook too, so a failed check comes back as a fix, not a question.

### 1 · Plant

```sh
cherry new junovale
```

```text
* creating cherry.exs
* creating .gitignore
* creating README.md
* creating AGENTS.md
* creating .claude/skills/publish/SKILL.md
* creating content/pages/index.md
* creating content/pages/about.md
* creating content/posts/2026-08-19-hello-cherry.md
* creating static/images/.gitkeep

Your orchard is planted at junovale. Next:

    cd junovale
    cherry serve          # live-reloading dev server
    cherry check          # the verifier agents build against
    cherry gen.action     # GitHub Pages deploy workflow
```

A working site, a first post, and an `AGENTS.md` that teaches the whole workflow to whatever coding agent you point at it. `cherry serve` gives you live reload from the first second.

### 2 · Write

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

That created `content/posts/2026-08-14-growing-season.md`: one file, valid frontmatter, `draft: true`. You never need the generator, though - a post is any markdown file you drop into `content/posts/` named `YYYY-MM-DD-slug.md`, and a page is any file in `content/pages/`, where `about.md` becomes `/about/`. The command just types the boilerplate and hands back the path, so pipe it straight into your editor, a script, or whatever else does your writing. Markdown is GitHub-flavoured, and the things markdown is bad at are one directive away:

```text
::figure{src="/images/harvest.jpg" alt="Crates at dusk" caption="Season one."}

::video{youtube="q6Yr9DkTn2k" title="The talk"}

:::tip{title="Rule of thumb"}
Size the queue for the promise, not the traffic.
:::
```

Figures with captions, video embeds that make zero third-party requests until clicked, and callouts. Framework-level, so they survive a theme swap.

Your work history is files too. Portfolio entries live under `content/portfolio/` in five folders (`positions`, `projects`, `talks`, `oss`, `education`), with your name, headline, and links in a `portfolio.yaml` at the site root. The generators scaffold an entry with valid frontmatter:

```sh
cherry gen.project "Cider Press" --json
```

```json
{
  "ok": true,
  "command": "gen.project",
  "data": {
    "path": "content/portfolio/projects/cider-press.md",
    "slug": "cider-press"
  }
}
```

Open the file it names and fill in the dates, tags, and highlights; `cherry gen.talk` does the same for talks. From those files cherry renders a dated timeline at `/portfolio/` and, because the project scaffold arrives with a `cv:` block (`include` opts it in, `weight` orders it), a curated employer-ready `/cv/` with machine-readable `cv.json` beside it. The [portfolio guide](/guides/portfolio-and-cv/) builds the whole thing from scratch.

### 3 · Verify

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

The diagnostic names the file, the rule, and the problem. Fix it, run again, exit 0. That's the verifier loop: build, check, fix, repeat. A broken link cannot reach production, because the deploy workflow runs the same check before it builds.

### 4 · Ship

```sh
cherry build
```

```text
Built 12 page(s), 2 asset(s) → _site
```

Same tree in, same bytes out: builds are deterministic, so your CI can prove nothing drifted. Push, and the GitHub Actions workflow from `cherry gen.action` deploys Pages. That's the entire pipeline.

</section>

<section class="beyond">

## Make it yours without forking anything

Styling is a ladder, and the first rung is one command:

```sh
cherry config tokens.--color-accent "#7c3aed"
```

```sh
tokens.--color-accent: light-dark(#b3173e, #f4718c) → #7c3aed (written to cherry.exs)
```

The write is surgical: comments and layout in `cherry.exs` survive byte-for-byte, and the override lands as one entry in the keyword list:

```elixir
tokens: ["--color-accent": "#7c3aed"]
```

Every theme publishes its tokens as an API (`cherry theme.tokens` lists them, documented). Light and dark are one value: tokens are `light-dark()` pairs, so the theme toggle flips a single `color-scheme` property and print always comes out clean. Need more than tokens? Drop an `assets/custom.css` that always wins, overlay a single template in EEx or HEEx, or `cherry theme.eject` with provenance recorded so upgrades merge instead of freezing. Each rung costs exactly as much ownership as you take.

</section>

<section class="beyond">

## More than a blog roll

The same content tree that builds your posts can carry your whole developer story. Portfolio collections (positions, projects, talks, open source, education) render a **timeline** at `/portfolio/`, **story pages** that cross-link everything sharing a tag, and a **`/cv`** shaped for employers: curated bullets, evidence-backed skills, a print stylesheet that produces a clean one-pager, and a machine-readable `cv.json` in JSON Resume format. All of it static, all of it typed, all of it checked by the same verifier as the blog. [Build yours in one guide.](/guides/portfolio-and-cv/)

</section>

<section class="closing">

## Start here

The [quick-start](/guides/quick-start/) goes from install to a deployed site in fifteen minutes. The [guides](/guides/) are project-shaped: build a portfolio with a hosted CV, create a theme of your own, wire up an agent. The [docs](/docs/) cover every verb, every config key, and every schema, with real output for all of it. This very site is Cherry's own dogfood: every page here is also [plain markdown](/index.md).

</section>
