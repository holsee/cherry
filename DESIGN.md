# Cherry — Design Document

*A modern take on Octopress: a static site generator for hackers, written in Elixir, driven by mix tasks, agent-first from day one.*

**Status:** Draft v1 — 2026-08-14
**Working name:** Cherry (`cherry` is unclaimed on Hex; no SSG collision found on GitHub)

---

## 1. Vision

Octopress made blogging feel like software development: your site was a repo, publishing was a rake task, and everything was hackable. Cherry keeps that spirit and fixes its fatal flaw — then adds the two things a 2026 developer site actually needs: a **developer story** (portfolio in the spirit of Stack Overflow Careers 2.0) and **first-class support for coding agents** as users of the tool and readers of the output.

**One-line pitch:** "Your site is a mix project. Your story is data. Your agent can run the whole thing."

### The three pillars

1. **Fast static pages** — pure prerendered HTML, zero JS by default, progressive enhancement only.
2. **Blog** — the Octopress workflow (`gen post` → write → `build` → `deploy`) with modern SEO and feeds out of the box.
3. **Portfolio** — a data-driven developer story: positions, projects, talks, open source; cross-linked with the blog through a shared tag taxonomy.

### Non-goals (v1)

- Theme marketplace / multi-theme ecosystem. One excellent default theme.
- Plugin API. A "plugin" is an Elixir module in your site repo.
- Dynamic server features (comments, auth). Static output only.
- Windows-path-hostile output. Cherry is developed on Windows; it must work everywhere.

---

## 2. The Octopress lesson (and the core architectural decision)

Octopress 2.x made your blog live *inside* the framework checkout. Upgrading meant merging framework changes into your content repo; it was so painful the 3.0 rewrite took years and the project died. The lesson:

> **Separate framework from content.** A Cherry site is a thin mix project that depends on the `cherry` hex package — the way a Phoenix app depends on `phoenix`. Framework updates are a version bump in `mix.exs`.

This one decision buys us:

- **Upgradability** — no merge hell, semver discipline instead.
- **Hackability** — the site is an Elixir project; users override behaviour with plain modules, no plugin API needed.
- **Task ergonomics** — mix tasks come from the dep; `mix help` discovers them.

### Language: Elixir (decided)

Go's single advantage is binary distribution — and that's Hugo's territory; a Go Cherry is "Hugo with different opinions." Elixir gives us mix tasks (exactly the rake ergonomics we want), EEx templating, MDEx (Rust comrak NIF — ~400 iterations/ms, orders of magnitude faster than Earmark), trivially parallel rendering via `Task.async_stream`, and a maintainer who enjoys the language.

Distribution friction is neutralized three ways:

1. `mix archive.install hex cherry_new` → `mix cherry.new my_site` (the phx_new pattern).
2. A published **GitHub Action** (`cherry-ssg/build-action`) so GH Pages users never touch Elixir locally.
3. A **standalone `cherry` binary** (Burrito-packaged: ERTS + app in a self-extracting executable) for people who don't want the mix workflow at all — with an idiomatic one-line install and upgrade path: `curl -fsSL https://cherrybomb.dev/install.sh | sh` to install, `cherry upgrade` to self-update. Release pipeline modeled on holsee/fizzy-cli — tag-triggered, native-runner build matrix (MDEx's Rust NIF makes cross-compilation the wrong bet), GitHub Releases with checksums + provenance attestation, prerelease tags never reaching `releases/latest`, brew/scoop manifests for stable tags (ADR 0007).

### Distribution: mix-first, binary-supported

The binary is a thin CLI dispatcher over the same core — `cherry build` ≡ `mix cherry.build`, verb for verb, flag for flag. One source of truth: tasks are wrappers around `Cherry.CLI.run/1`, so mix and binary can never drift.

The one real consequence: a prebuilt binary can't *compile* site-local Elixir modules. So Cherry defines two site modes with an explicit capability line between them:

| Mode | Site is | Extensibility | Audience |
|---|---|---|---|
| **Project mode** | mix project depending on `cherry` | Full — site-local modules hook any pipeline stage | Elixir developers (the Octopress-spirit audience) |
| **Binary mode** | content + config directory, no `mix.exs` | Config + optional `.exs` extension scripts, interpreted at runtime (`extensions/*.exs`) | Everyone else |

The `.exs` escape hatch matters: the Burrito release ships the Elixir compiler apps, so runtime-interpreted extension scripts work identically in both modes. A binary-mode site that outgrows scripts converts to project mode by adding a `mix.exs` — nothing else moves. Every core feature (all three pillars, themes, deploy, check) works in both modes; only compiled site-local code is project-mode-only.

---

## 3. Prior art — what we take from each

| Project | What we take | What we leave |
|---|---|---|
| **Octopress** | Task-driven workflow; opinionated defaults; deploy built in; hacker aesthetic | Content living inside the framework repo |
| **Tableau** (Elixir, v0.26, active) | Proof the model works; extension lifecycle hooks (`pre_build`/`pre_render`/`pre_write`/`post_write` over a token); MDEx converter; permalink templating (`:year/:month/:title`) | Pages-as-modules as the *primary* authoring mode (Cherry is content-first: markdown in, pages out; Elixir modules are the escape hatch, not the default) |
| **Astro** | Content collections with schema validation; loader/schema separation; optional schemas for gradual adoption; build-time validation errors that name the file and field | The JS ecosystem |
| **Hugo** | Taxonomy model; base-URL discipline for subpath hosting; build speed as a feature | Go templates; config sprawl |
| **Zola** | Single sane default for everything; shortcodes | — |
| **Eleventy** | Data cascade (global data → collection data → page frontmatter) | — |
| **NimblePublisher** | Frontmatter-in-markdown format (`%{...}` elixir map or YAML); compile-time ergonomics | Compiling content into the app module (Cherry reads content at build runtime — simpler mental model for a generator, no recompile loop) |

**Compete-or-differentiate vs Tableau:** differentiate. Tableau is a fine general SSG for Elixir developers. Cherry is opinionated about *what a developer's site is* (blog + story), ships design as a feature, and treats agents as first-class users. We should credit it and steal its lifecycle-hook shape, which is well-designed.

---

## 4. Architecture

### Build pipeline

```
sources                 stages                              output
─────────              ────────                            ────────
content/**/*.md   →    load        (read files, parse frontmatter)
data/*.yaml       →    validate    (collection schemas; fail with file+field errors)
config            →    transform   (MDEx render, shortcodes, highlighting)
                  →    layout      (EEx layouts + components)
                  →    emit        (HTML, feeds, sitemap, llms.txt, md mirrors)
                  →    post        (search index, fingerprints — optional)
                                                            _site/
```

- Each stage takes and returns a **build token** (a map: config, collections, pages, diagnostics) — Tableau's proven shape.
- Site-local modules can hook any stage boundary (this is the whole "plugin system": a behaviour with `stage/2` callbacks and a priority, registered in config).
- Pages render in parallel (`Task.async_stream`); content graph digests enable incremental rebuilds in `serve` mode.
- **Determinism is a contract:** same inputs → byte-identical `_site/`. No timestamps injected at build time except where content demands it. This matters for CI caching and for agents verifying their own work.

### Content model: collections with schemas

Astro's best idea, in Elixir clothes. A collection = a directory + a schema + routing rules.

Built-in collections:

| Collection | Directory | Notes |
|---|---|---|
| `pages` | `content/pages/` | Freeform; permalink from path or frontmatter |
| `posts` | `content/posts/` | Dated; drafts + future-post filtering; tags; `/:title/` permalink default (matches the old Octopress site) |
| `portfolio/positions` | `content/portfolio/positions/` | Role, org, dates, tech tags, highlights |
| `portfolio/projects` | `content/portfolio/projects/` | Links, artifacts, tech tags, status |
| `portfolio/talks` | `content/portfolio/talks/` | Event, date, video/slides links |
| `portfolio/oss` | `content/portfolio/oss/` | Repo link, role (author/maintainer/contributor) |

- Schemas are NimbleOptions-style keyword specs; validation errors name the file, the field, and what was expected. Schemas are **introspectable** (`mix cherry.schema posts --json`) — this is a load-bearing agent feature.
- Users define custom collections in config with their own schema + permalink + layout.
- Frontmatter format: YAML (ecosystem-portable; agents and humans both know it).

### The portfolio (developer story)

The Careers 2.0 insight was that a developer's story is a *timeline of typed entries*, not a résumé PDF. Cherry models it as data:

- Every portfolio entry carries `tags:` from the **same taxonomy as blog posts**. The story page for "Elixir" shows positions, projects, talks, *and every blog post* tagged Elixir. This cross-linking is the feature; nobody in SSG land does it.
- Rendered as: timeline view (default), plus per-tag story pages.
- Emits JSON-LD `Person` (with `worksFor`, `alumniOf`, `knowsAbout`) — the portfolio *is* the structured data.
- A `portfolio.yaml` at the root holds the profile itself (name, headline, location, links, avatar). Contact email is **off by default** (spam harvesting on public static pages is real); opt-in via config.

### One profile, two modes: the CV and its timeline

Careers 2.0's killer use was linking an employer to your profile instead of sending a
CV. Cherry ships the profile as **one page family with two modes of the same
portfolio data**, linked by a view switcher:

1. **The CV view** (`/cv/`, template `cv`) — the default mode: a Careers-profile
   two-column page that *reads like a CV* — `cv:`-curated entries with story-linked
   tag pills in the main column, derived skills and open source in the sidebar.
   Employer-shaped, scannable, print-first: print and PDF are output forms of this
   view, not its reason for existing.
2. **The timeline mode** (`/cv/timeline/`, template `portfolio_timeline`) — the same
   profile over the *full* portfolio, chronological and rich, cross-linked into the
   blog through the shared tag taxonomy. Curation never hides work here.

`/portfolio/` ships as a meta-refresh redirect to its successor, so old links keep
working; it stays out of the sitemap with a canonical to the new home.

The design principle is strict: **both views are projections of the same portfolio
data — never a second dataset.** The moment CV content lives in its own file, it
drifts, and you're maintaining a CV again.

- **Curation, not duplication.** Entries opt in via frontmatter:
  `cv: {include: true, weight: 10, highlights: [...]}`. The markdown body stays the
  long-form story; `highlights` are the CV's punchy bullets. No `cv:` block →
  timeline-only. An `education` collection joins the portfolio built-ins.
- **Evidence-backed skills** — the differentiator. The CV's skills section is
  *derived*: tags aggregated across positions/projects, weighted by duration and
  recency, each one linking to that tag's story page. "Elixir — 6 yrs" is a click
  away from the actual projects, talks, and posts. A paper CV claims; this one shows.
- **Print and PDF are first-class outputs.** The `cv` template is designed for
  `@media print` from day one: black-on-white regardless of site theme, page-break
  discipline (never split an entry), no chrome, A4/Letter-safe. Baseline "Download
  PDF" is the browser's print dialog (zero JS, pixel-perfect because we designed for
  it); a build-time rendered PDF artifact (`/cv.pdf`) is a planned enhancement once
  the toolchain cost is justified (tracked as a GitHub issue).
- **Machine-readable**: `/cv.json` in the [JSON Resume](https://jsonresume.org)
  standard schema (ATS tools and agents consume it; the standard's name stays theirs,
  the route is ours), plus the usual markdown mirror. JSON-LD `Person` derives from
  the same data.
- **Discretion, the static-site way**: visibility is `:public | :unlisted | :off`.
  Unlisted builds the page but keeps it out of nav, sitemap, feeds, and llms.txt,
  with `noindex` — share the URL with an employer without announcing a job hunt on
  your homepage.
- **Identity routes.** The CV can additionally build under identity-carrying URLs —
  `/cv/handle/`, `/cv/first.lastname/` — configured as independent routes, each
  with its own slug, presented identity (`handle` → the page leads with "@handle";
  `name` → it leads with the real name), and its own visibility. Both can be live at
  once (public handle for the community, unlisted real name for employers — or any
  combination). Exactly one route is canonical: all others emit `rel=canonical` to
  it, and bare `/cv/` serves or redirects to it, so duplicate-content SEO stays
  clean. No routes configured → plain `/cv/` only; the identity layer is opt-in.
  Every route directory carries its own `cv.json` and markdown mirror.
- **Freshness from content, not the clock**: the "Updated August 2026" line derives
  from the newest included entry (or an explicit `updated:` in `portfolio.yaml`) —
  the determinism contract holds.
- Both `portfolio_timeline` and `cv` are part of the **theme contract inventory**, so
  every theme ships both and swapping never loses either mode.

---

## 5. The task surface (Octopress → Cherry mapping)

| Task | Purpose |
|---|---|
| `mix cherry.new my_site` | Scaffold (via `cherry_new` archive): content dirs, config, theme, `AGENTS.md`, CI workflow |
| `mix cherry.gen.post "Title"` | New draft post with valid frontmatter; prints (or `--json`-returns) the path |
| `mix cherry.gen.page` / `gen.project` / `gen.talk` … | Same for other collections |
| `mix cherry.build` | Full build → `_site/`. Flags: `--drafts`, `--future`, `--json` |
| `mix cherry.serve` | Bandit dev server + file watcher + live reload |
| `mix cherry.check` | Verifier: broken internal links, missing descriptions/alt text, duplicate titles, feed validity, schema drift. Structured output; nonzero exit on failure |
| `mix cherry.publish path/to/draft.md` | Draft → dated, published post |
| `mix cherry.schema <collection>` | Print a collection's frontmatter schema (`--json` for agents) |
| `mix cherry.gen.action` | Generate the GitHub Pages deploy workflow |
| `mix cherry.deploy` | Push `_site/` (gh-pages branch, rsync target, or "you have CI, don't run this locally" advice) |

Terminal experience: clean, fast, quiet by default, `--verbose` for humans debugging, `--json` for machines. Every task obeys both. Exit codes mean things.

---

## 6. Agent-first (the novel pillar, specified)

Two halves: **agents operating the tool** and **agents reading the output**.

### Operating

- Every task: `--json` mode, deterministic behaviour, documented exit codes.
- `mix cherry.check` is the agent's verifier loop: build → check → fix diagnostics → repeat. Diagnostics are structured (`{file, line?, rule, message, severity}`).
- `mix cherry.schema --json` tells an agent exactly what valid frontmatter looks like before it writes a file.
- Scaffolded sites ship **`AGENTS.md`** documenting the full workflow (create → write → build → check → deploy), plus a `.claude/skills/` publish skill.
- Dry-run flags on anything that writes (`gen.*`, `publish`, `deploy`).

### Reading (the published site)

- **`/llms.txt`** — generated index of the site in markdown, per the llmstxt.org convention.
- **Markdown mirrors** — every page emits `index.md` alongside `index.html`; agents read content without scraping HTML. Cheap for us, almost unheard of, genuinely useful.
- **JSON Feed** alongside Atom.
- Honest `sitemap.xml` and stable, canonical URLs.

---

## 7. SEO — default-on, zero config

Canonical URLs; Open Graph + Twitter cards; JSON-LD (`BlogPosting` per post, `Person` from portfolio); `sitemap.xml`; `robots.txt`; Atom + JSON feeds; 404 page; trailing-slash discipline (one canonical form, consistently); per-page `description` enforced by `cherry.check`, not silently defaulted. Social card images: static fallback in v1; generated OG images are a v3 candidate.

---

## 8. Theming: one excellent default, swappable by contract

Cherry ships one excellent default theme — and a theme *system* designed so that swapping themes is one config line and customizing never strands you. The system is built from the lessons of everyone who tried before:

| System | Lesson taken |
|---|---|
| **Jekyll** (gem themes) | Path-shadowing is the right override UX — but theme files hidden inside a gem create friction ("where do I even look?"), and hand-copied overrides silently freeze: "making copies of theme files will prevent you from receiving any theme updates on those files." Fix both. |
| **Hugo** (lookup order) | Site-over-theme interleaved lookup is powerful, but Hugo's specificity matrix (kind × type × layout × format × language) got confusing enough that v0.146 overhauled it. Keep the lookup order to three levels, and make it printable. |
| **shadcn/ui** (open code) | Owning the actual code beats wrapping a black box, and a CLI with flat metadata makes distribution tractable for humans *and* agents. But even shadcn's FAQ asks "how do I pull upstream updates?" without a real answer. Provenance tracking at eject time is the missing piece. |
| **WordPress** (child themes) | Customization that lives in a *separate layer* from the theme survives theme updates. Twenty years of proof. |
| **Eleventy/Astro** (starter repos) | "Theme = template repo you fork" is fork-and-drift by design. Avoid as the primary model. |

### The theme contract (what makes swapping real)

A theme is a package — a hex dep in project mode, a plain directory in binary mode (templates evaluate at runtime — classic EEx or HEEx, the extension decides — so binary-mode sites get full themes, not a reduced tier). Every theme carries a `theme.exs` manifest declaring:

- **Contract version** (`cherry_contract: "1.x"`) — the framework's theme API is versioned; `cherry.check` fails loudly on mismatch instead of half-rendering.
- **Template inventory** — the named templates the contract requires (`layout`, `post`, `page`, `post_list`, `tag`, `portfolio_timeline`, `cv`, `404`, …) and the assigns each receives. Fixed names + fixed assigns are *why* swap works.
- **Token manifest** — every CSS custom property the theme uses, with default and description. Tokens are the theme's public styling API.
- Metadata: name, version, screenshot, description.

Content never references theme internals — shortcodes/components are framework-level, not theme-level. (Jekyll theme swaps break precisely because content accumulates theme-specific includes; the contract forbids that failure mode structurally.)

Swapping: `theme: {:hex, :cherry_theme_dusk}` → `theme: {:hex, :cherry_theme_ink}`. Site-local overrides are keyed per-theme (`theme/dusk/…`), so a swap never silently applies overrides written against a different theme's templates.

### The customization ladder (shallow → deep, each rung explicit)

1. **Config** — title, nav, accent color, fonts. No files touched.
2. **Tokens** — override any manifest token: `tokens: ["--color-accent": "#7c3aed"]` in `cherry.exs`, written by hand or via `cherry config tokens.NAME VALUE`; `cherry theme.tokens` lists the API. Names are validated against the manifest — a typo errors with the nearest real token. Most users never leave this rung; light/dark both derive from it.
3. **CSS append** — `assets/custom.css` loads last, always. The "I just want to tweak it" pressure valve. Theme CSS lives in `@layer theme`; rungs 2–3 are unlayered and ride the framework-owned head, so they beat the theme by cascade-layer rules in any theme, with no specificity arithmetic.
4. **Shadow with provenance** — `mix cherry.theme.eject post.html.eex` copies the template into the site's theme overlay *with a recorded lineage* (theme name, version, content hash). Never hand-copy; the task records where the file came from.
5. **Own the theme** — `mix cherry.theme.eject --all` vendors everything; `mix cherry.gen.theme` scaffolds a fresh contract-conforming theme (this is also how the default theme is just "theme #1," not privileged code).

### Managed drift (the piece nobody ships)

Because rung 4 recorded provenance, theme upgrades become a three-way comparison (base you ejected from / new upstream / your copy):

- `mix cherry.theme.diff` — upstream changed + you didn't touch it → flagged auto-updatable; both changed → three-way diff to resolve.
- `mix cherry.check` warns when any shadowed file is stale against the installed theme version.

This directly answers Jekyll's frozen-copies problem and shadcn's unanswered FAQ — and it's mechanical work an agent can drive (`--json` diagnostics, as everywhere).

### Discoverability

`mix cherry.theme.list` shows the active theme's full template inventory and token manifest, what the site currently shadows, and what's stale — no spelunking through deps. `mix cherry.theme.which post` prints exactly which file will render (site overlay → theme → framework fallback; three levels, never more).

### The default theme itself

- **Design tokens on `:root`** (full light palette), redefined under `prefers-color-scheme: dark` and under an explicit `data-theme` attribute so a manual toggle beats system preference. No-flash inline script reads `localStorage` before first paint.
- **Code blocks follow the theme for free:** MDEx's `html_linked` formatter (Lumis engine — it superseded the old `html_multi_themes` API) emits class-based tokens with no baked colors; the theme's own `--syn-*` custom properties color them in both renditions, so the toggle swaps code and prose as one world — no JS re-highlighting.
- Hand-rolled tokens CSS, no Tailwind: design is a feature of this product, the CSS should be readable, and zero node/binary build deps keeps the pipeline pure. (Sites that want Tailwind add it as a watcher; we don't ship it.)
- Zero JS by default; enhancements (theme toggle, search UI) are `<script>` islands that fail soft — authored in TypeScript in the cherry repo, shipped as compiled JS assets (user site builds stay node-free).
- Design pass will be done with the impeccable skill when we build it. Typography-first; the old site's "code and stuff" personality, modernized.

**Search:** optional, and two engines answer to the same `search:` key.

`search: cherry` is the built-in one: an inverted index built in-process from the parsed documents and emitted as `search/index.json`, queried by a ~2 kB island shipped from `priv/search/`. No Node, no npm, no network, no subprocess — so it works wherever the binary works, and because it is a pure function of the content it lands inside the deterministic build and the double-build gate covers it. Ranking is tf-idf over emitted weights, with titles counted three times and tags twice. Deliberately simple: no stemmer beyond plural folding, no multilingual support, no wasm.

`search: pagefind` remains for sites that want the better engine and accept its cost — `cherry.build` shells out to `npx pagefind` after emit, which needs Node and the npm registry on whatever machine builds the site. It indexes the rendered HTML rather than the source, handles many languages, and ships a richer UI.

The default is neither. A site that sets nothing pays for nothing, and the core stays dependency-free.

---

## 9. Hosting: GH Pages first-class, anywhere trivially

The portability guarantee is that **`_site/` is a plain directory of files**. Anything that can serve files can host a Cherry site.

GitHub Pages specifics (the first-class path):

- `mix cherry.gen.action` emits the modern workflow: `setup-beam` → `mix cherry.build` → `actions/upload-pages-artifact` → `actions/deploy-pages`. No gh-pages branch juggling.
- `.nojekyll` always emitted; `CNAME` from config.
- **Base-path correctness** for project pages (`user.github.io/repo/`): one `base_url` config; every generated URL, feed link, canonical, and asset reference respects it. This is where every SSG's Pages story quietly breaks; ours gets tests.
- The published build-action means "fork template repo → edit a markdown file in the web UI → site deploys" works with zero local toolchain.
- **Cherry's own site eats the dogfood**: the project site is built with Cherry, deployed as a GitHub Page from `holsee/cherry`, and served at **cherrybomb.dev** (custom-domain CNAME + apex/www routing) — so the GH Pages + custom domain path is exercised by us before anyone else.

Elsewhere: Netlify/Cloudflare/Vercel need nothing but "build command + output dir" documented; `cherry.deploy --target` covers rsync/branch-push for the self-hosted crowd.

---

## 10. Delivery phases

> All three phases shipped: Phase 1 in the 0.1.0 release candidates, Phases 2 and 3
> across 0.1.0 and 0.2.0. This section stays as the historical record; ongoing work
> lives in GitHub issues and milestones.

**Phase 1 — Core (usable Octopress successor)**
Pipeline (load→validate→transform→layout→emit), `pages` + `posts` collections, tags, default theme with light/dark, theme contract v1 (manifest, tokens, shadowing via `theme.eject` with provenance, `theme.list`/`theme.which`), `gen.post`/`build`/`serve`/`publish`, Atom feed, sitemap, canonical/OG/JSON-LD basics, GH Pages action + base-path handling. Migrate holsee.github.io content from `original/` (source branch markdown) as the dogfood.

**Phase 2 — Portfolio**
Portfolio collections + schemas (incl. `education`), `portfolio.yaml` profile, timeline theme section, shared-taxonomy story pages, **the CV view** (`/cv/` — a web page that reads like a CV, print-ready, curation frontmatter, derived skills, `/cv.json`, visibility controls), `Person` JSON-LD, `gen.project`/`gen.talk`. Also `mix cherry.gen.theme` + a second official theme — the proof that the swap contract is real, not aspirational. Decided (2026-08-14): the second theme is **`cherrybomb`**, carrying the brand's graffiti/retrowave energy (logo art in `assets/`); the default theme stays clean and brand-free.

**Phase 3 — Agent, binary & polish**
`cherry.check` suite, `--json` everywhere it isn't yet, llms.txt + markdown mirrors, JSON Feed, `cherry.schema`, scaffolded `AGENTS.md` + skill, Pagefind integration, published build-action, `cherry_new` archive on Hex, **`theme.diff` managed-drift upgrades**, **Burrito standalone binary + binary-mode sites** (the `Cherry.CLI.run/1` seam that makes it cheap is built in Phase 1).

(Ordering note: minimal `--json` on `gen.post`/`build` lands in Phase 1 — it's cheap and we want agents dogfooding from the start.)

---

## 11. Open decisions

| Decision | Lean | Why it can wait |
|---|---|---|
| Package/repo naming: `cherry` vs `cherry_ssg` for the hex package | `cherry` (it's free) | Claim it early, decide branding later |
| ~~EEx vs HEEx for layouts~~ | **Settled (0.2.0): both — the file extension decides.** `.html.heex` renders with HTML-aware escaping and function components (runtime-compiled, so the binary gets it too; a 0.2.0 spike measured ~0.5ms/render and ~5MB of release weight for the `phoenix_live_view` chain) and wins over the `.eex` twin at the same lookup level. Official themes stay EEx; HEEx is the overlay/rewrite lane, and a `.heex` overlay reports as `rewritten` — owned, outside provenance. Themes may ship `components.exs` (`use Phoenix.Component`) for `<.card>`-style composition. | — |
| ~~Shortcodes/components in markdown (Zola-style `{{ youtube(id) }}`)~~ | **Settled (0.2.0): shipped, remark-directive syntax** — `::figure`, `::video` (zero-request facade), `:::note…:::` containers; framework-level so theme swaps survive; misuse is a `component` check diagnostic, never a broken build. | — |
| Generated OG card images | v3, via `vix`/libvips or resvg | Static fallback is fine initially |
| Incremental builds | serve-mode only at first | Full builds are fast enough at blog scale; don't buy complexity early |
| Binary release channel | GitHub Releases + `brew`/`scoop` manifests | Only matters once the binary ships in Phase 3 |

## 12. Risks

- **Scope**: three pillars + agent tooling is a real product. Mitigation: the phases are each independently shippable; Phase 1 alone replaces the old site.
- **Tableau overlap**: differentiation must stay real (portfolio, agents, design, workflow). If it collapses into "another Elixir SSG," consider contributing upstream instead.
- **Windows**: we develop on it — file watching, path separators, and the `|`-in-filename class of bugs (see the `original/` clone) get first-party attention. CI matrix: ubuntu + windows.
