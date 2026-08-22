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
<li><strong>One binary.</strong> No runtime to install; <code>cherry upgrade</code> swaps itself, checksum-verified.</li>
<li><strong>Typed content.</strong> Unknown frontmatter is a build error, not a mystery.</li>
<li><strong>Deterministic builds.</strong> Same tree in, same bytes out, gated in CI.</li>
<li><strong>A real verifier.</strong> <code>cherry check --strict</code> returns structured diagnostics, not vibes.</li>
<li><strong>Themes that survive upgrades.</strong> Tokens are the styling API; ejected templates carry provenance.</li>
<li><strong>Light and dark as one value.</strong> Colour tokens are <code>light-dark()</code> pairs; print stays clean.</li>
<li><strong>Content components.</strong> Figures, privacy-preserving video facades, and callouts as directives.</li>
<li><strong>Two template languages.</strong> EEx or HEEx, decided by file extension.</li>
<li><strong>Developer timeline + CV.</strong> A dated timeline, story pages, and a print-ready CV with JSON Resume output.</li>
<li><strong>SEO you can't forget.</strong> Canonical, Open Graph, JSON-LD, feeds, sitemap: default-on in every theme.</li>
<li><strong>Markdown all the way out.</strong> Every route ships its markdown twin, plus <a href="/llms.txt">/llms.txt</a>.</li>
<li><strong>AI-agent-friendly CLI.</strong> Every verb has a <code>--json</code> envelope; the <a href="/guides/agents/">shipped skill</a> teaches the whole loop.</li>
</ul>

</section>

<section class="loop">

## The tour

Cherry turns a folder of markdown files into a finished website: pages, a blog, and a developer portfolio with a CV. Everything below is the real workflow with real output - every command shown here was run, and this site is built by the same tool it describes.

### 0 · Let your agent cook

Prefer to delegate? Cherry ships a [skill](/guides/agents/) that teaches a coding agent every verb, the JSON envelopes, and the verify-fix loop. One command installs it (swap the agent flag for `github-copilot`, `cursor`, `codex`, and friends):

```sh
gh skill install holsee/cherry cherry --agent claude-code
```

Then every step below is something you can simply ask for:

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

The skill carries the error-recovery playbook too, so a failed check comes back as a fix, not a question.

### 1 · Start a site

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
* creating content/posts/2026-08-22-hello-cherry.md
* creating static/images/.gitkeep

Your orchard is planted at junovale. Next:

    cd junovale
    cherry serve          # live-reloading dev server
    cherry check          # the verifier agents build against
    cherry gen.action     # GitHub Pages deploy workflow
```

Nine files, three of which you will actually touch: `cherry.exs` is the config, `content/pages/` holds your pages, `content/posts/` your posts. `cherry serve` gives you live reload from the first second, and `AGENTS.md` teaches the workflow to whatever coding agent you point at it.

The [quick-start](/guides/quick-start/) goes from here to a deployed site in fifteen minutes.

### 2 · Create a page

No generator needed. A page is a markdown file in `content/pages/`, and the filename is the URL: `about.md` is `/about/`, so a new file called `now.md`:

```markdown
---
title: Now
description: What I am working on right now.
---
## Now

Pressing apples, mostly.
```

is live at `/now/` the moment you save it. Markdown is GitHub-flavoured, and the things markdown is bad at are one directive away:

```text
::figure{src="/images/harvest.jpg" alt="Crates at dusk" caption="Season one."}

::video{youtube="q6Yr9DkTn2k" title="The talk"}

:::tip{title="Rule of thumb"}
Size the queue for the promise, not the traffic.
:::
```

Figures with captions, video embeds that make zero third-party requests until clicked, and callouts - framework-level, so they survive a theme swap. Details in [content](/docs/content/) and [components](/docs/components/).

### 3 · Write a blog post

A post is a markdown file in `content/posts/` named `YYYY-MM-DD-slug.md`. The generator types the boilerplate and hands back the path:

```sh
cherry gen.post "Growing season" --json
```

```json
{
  "ok": true,
  "command": "gen.post",
  "data": {
    "date": "2026-08-22",
    "path": "content/posts/2026-08-22-growing-season.md",
    "slug": "growing-season"
  }
}
```

Open that file and it is yours - valid frontmatter, `draft: true`, waiting for words:

```markdown
---
title: "Growing season"
draft: true
tags: []
---
```

Write the post, then publish. Publishing flips the draft flag off and re-dates the file to today, because the filename is the source of truth for a post's date:

```sh
cherry publish growing-season
```

```text
Published: content/posts/2026-08-22-growing-season.md → content/posts/2026-08-22-growing-season.md
```

The whole rhythm, drafts to feeds, is the [authoring loop guide](/guides/authoring-loop/).

### 4 · Add to your portfolio

Your work history is files too. Entries live in five folders under `content/portfolio/` (`positions`, `projects`, `talks`, `oss`, `education`), and your name and links go in a `portfolio.yaml` at the site root:

```yaml
name: Juno Vale
headline: Systems engineer who ships small, sharp tools
location: Belfast
links:
  - label: GitHub
    url: https://github.com/junovale
```

The generators scaffold an entry with valid frontmatter:

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

Open the file it names and fill in what happened - dates, tags, highlights - exactly like editing any other markdown file:

```markdown
---
title: "Cider Press"
status: active
start: 2026-02-01
links:
  - label: Source
    url: https://github.com/junovale/cider-press
tags: [elixir, orchard]
highlights:
  - Batch scheduler that presses 400 kg of apples a day unattended
  - Zero-downtime deploys since February
cv:
  include: true
  weight: 10
---

The press line, from crate to bottle, as one supervised Elixir application.
```

`cherry gen.talk` scaffolds talks the same way (event, date, video link), and `cherry schema portfolio/projects` prints every field an entry accepts. What those files turn into is a story of its own - [the next section](#the-devlog-that-becomes-your-cv).

### 5 · Verify

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
    "message": "Checked 35 page(s): 1 error(s), 0 warning(s).",
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

The diagnostic names the file, the rule, and the problem. Fix it, run again:

```text
Checked 33 page(s): all clear.
```

That's the verifier loop: build, check, fix, repeat. A broken link cannot reach production, because the deploy workflow runs the same check before it builds. Every rule is documented in the [check guide](/guides/check/).

### 6 · Ship

```sh
cherry gen.action
```

```text
Wrote .github/workflows/pages.yml (CNAME: example.com) — enable it once under Settings → Pages → Source → GitHub Actions.
```

```sh
cherry build
```

```text
Built 33 page(s), 4 asset(s) → _site
```

Builds are deterministic - same tree in, same bytes out - so CI can prove nothing drifted. Push, and the workflow checks, builds, and deploys Pages. Prefer Cloudflare? `cherry gen.action --host cloudflare` writes that pipeline instead. Both are covered in the [deploy guide](/guides/deploy/) and its [Cloudflare twin](/guides/deploy-cloudflare/).

</section>

<section class="beyond">

## The devlog that becomes your CV

A blog records what you were thinking. The portfolio records what you shipped. Keep both in the same content tree and something better than either falls out: a running, public record of your work - every position, project, talk, open-source contribution, and course, logged as one markdown file when it happens, in exactly the detail you want the world to see.

From those files, three views, no extra work:

- **The full timeline** at `/cv/timeline/`: everything you have ever done, dated and interleaved - positions as ranges, projects with status, talks as moments in time. Curation never hides work here; this is the complete history, and it only grows.
- **Story pages** at `/story/TAG/`: one thread per tag. The job, the projects it produced, the talks about them, and the blog posts written along the way, cross-linked on a single page - tags are one taxonomy across the whole site, so your writing and your work weave together on their own.
- **The CV** at `/cv/`: the employer-shaped cut. A `cv:` block on each entry opts it in and orders it, the print stylesheet turns it into a clean one-pager, and a machine-readable `cv.json` ships beside it in JSON Resume format:

```json
{
  "$schema": "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json",
  "basics": {
    "label": "Systems engineer who ships small, sharp tools",
    "name": "Juno Vale",
    "profiles": [{"network": "GitHub", "url": "https://github.com/junovale"}]
  }
}
```

The payoff is the habit. Write the entry the week you ship the thing, while the details are still sharp, and your timeline and CV stay current forever - no night-before-the-interview scramble to reconstruct five years of work from old repos and older memories. All of it static, all of it typed, all of it checked by the same verifier as the blog. [Build yours in one guide.](/guides/portfolio-and-cv/)

</section>

<section class="beyond">

## Make it yours without forking anything

Styling is a ladder, and the first rung is one command:

```sh
cherry config tokens.--color-accent "#7c3aed"
```

```text
tokens.--color-accent: (unset) → #7c3aed (written to cherry.exs)
```

Every theme publishes its tokens as an API (`cherry theme.tokens` lists them, documented), and colour tokens are `light-dark()` pairs, so one value covers both modes and print always comes out clean. Need more than tokens? Drop an `assets/custom.css` that always wins, overlay a single template in EEx or HEEx, or `cherry theme.eject` with provenance recorded so upgrades merge instead of freezing. Each rung costs exactly as much ownership as you take.

The ladder is the [themes guide](/guides/themes/); building your own from scratch is the [creating a theme guide](/guides/creating-a-theme/); the full token and template reference is [theming](/docs/theming/).

</section>

<section class="closing">

## Start here

The [quick-start](/guides/quick-start/) goes from install to a deployed site in fifteen minutes. The [guides](/guides/) are project-shaped: build a portfolio with a hosted CV, create a theme of your own, wire up an agent. The [docs](/docs/) cover every verb, every config key, and every schema, with real output for all of it. This very site is Cherry's own dogfood: every page here is also [plain markdown](/index.md).

</section>
