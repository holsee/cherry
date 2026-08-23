# Changelog

All notable changes to Cherry are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning follows SemVer.

Entries are terse one-liners linked to their PR: `- Thing that changed. (#12)`

## [0.6.0] — 2026-08-23

### Added
- `deploy_paths` site config: declare root-relative prefixes a deployment serves beside the build (`deploy_paths: ["t/"]` for the theme exhibition at /t/), and `cherry check` treats internal links under them as satisfied - so the gallery's demo links are plain root-relative URLs that work locally and deployed, with no exhibition-specific link rewriting. (#142)
- Every official theme gains a "Using THEME" page on cherrybomb.dev (`/themes/NAME/`): install, the styling ladder applied to that theme, the full token API with light/dark values and roles, the shipped-vs-inherited template split, and how to point a coding agent at the Cherry way. Generated from each theme's own manifest by `scripts/gen_theme_docs.exs`, so the pages cannot drift; the landing page shows six theme cards right after Plant, and the checklist links the gallery. The gallery itself becomes a hub-style card grid - each screenshot in a small browser-window frame with Live demo and Customise links - and the theme exhibition moves under cherrybomb.dev/t/ (built into the same Pages deployment; no themes. subdomain needed). (#142)
- Ten more official themes take the catalog to thirty, in three bands. The limit: `atlas` (the blog index as a map you pan and zoom, posts in tag regions, a minimap, a keyboard path and a list view), `bellows` (Anybody's width axis bound to scroll with CSS scroll-driven animations, no script), `mercury` (a WebGL liquid-chrome pool that dents under the pointer, the title cast in the same metal), `flipdot` (a departure board: titles flip in per character, Doto's dot-matrix face). The technique: `transit` (cross-document View Transitions carry a title from the index into its post, a scroll-timeline progress rule, a sticky title rail, zero JS), `loom` (a verlet cloth behind the mast, warp-thread rules, a weaver's draft index), `topo` (a live marching-squares contour field that goes flat under the reading column). The style: `desktop` (System 7 / Win98 chrome played straight: window, bevels, list view, dialog 404), `swiss` (the International Typographic Style on a visible twelve-column grid), `sketchbook` (hand-drawn rules that draw themselves on a view timeline, paper grain, tape). Every one keeps the rules: the same token API, no colour literals, contract 1.1, honest degradation, self-hosted OFL faces with the flash-free loading pass, a DESIGN.md and a conformance test. (#142)
- Fifteen new official themes take the catalog to twenty, under one mantra: variation is key. Different layouts (centred masts, a left rail, a newspaper masthead, bento tiles, hero bands, a ruled table, magazine columns), different motion (canvas2d star, grain, leaf and wave fields; WebGL warp streaks and an aurora; kinetic type on text rings; cinematic scroll scenes; a looping video hero), and different styles (editorial, brutalist, risograph, CRT, product-page bento). Ten are strongly inspired by the ThreeUI catalog - `constellation`, `warp`, `erosion`, `vortex`, `halftone`, `isometric`, `sylva`, `tideform`, `cathode`, `kage` - each with its own self-hosted latin-subset face (Unbounded, Geist, Syne, Fraunces, Bricolage Grotesque, Archivo, Sora, Newsreader, Schibsted Grotesk, Azeret Mono, Instrument Serif, Hanken Grotesk; all OFL, 9 to 46 KB per face); four follow alternate modern styles - `broadsheet`, `brutalist`, `cinema` (the video-background theme, a 200 KB silent loop shipped as a theme asset), `bento`; and `showoff` stacks every technique at once on purpose. Every one keeps the rules: the same token API as `default`, no colour literals outside token lines, contract 1.1 partial shipping (from zero templates to three), and honest degradation for no-JS, reduced motion, and print. The token gate now iterates every built-in theme, and the gallery and exhibition carry all twenty. (#138)
- Code block headers: a fence that names a language gets a slim bar above the block - the language in small text beside its editor-style file icon (devicon glyphs shipped in both official themes as `currentColor` CSS masks; unknown languages get a generic file glyph). `title="path"` in the fence info adds the file path, Docusaurus-style; both parts optional, bare fences unchanged. The copy button rides the bar when one exists, so it never covers code. (#111)
- cherrybomb.dev gains `/themes/`: a gallery of every official theme with light/dark screenshot pairs (captured by the QA harness, following the viewer's scheme) linking into the live exhibition at themes.cherrybomb.dev, where every theme wears the same demo site with identical routes. (#137)
- New official theme `prism` (0.6.0 catalog, cutting-edge lane proof): a gradient-mesh atmosphere painted live by a ~5 KB hand-written WebGL fragment shader - no three.js, zero requests - under glass surfaces (backdrop blur with honest solid fallback). The mesh's uniforms come from the theme tokens via a documented token-to-uniform bridge, so `cherry config tokens.--color-accent` restyles the shader like a link; JS-off gets a CSS poster gradient from the same tokens, reduced motion freezes the first frame, print hides it entirely. Ships one template (its layout, mounting the canvas + island) and inherits the rest; Instrument Sans latin subset self-hosted (56 KB, OFL). Theme-local islands are now a documented convention (assets/js/themes/NAME/ built per theme). (#135)
- New official theme `teletype` (0.6.0 catalog, clinical lane): the all-mono devlog theme - Noto Sans Mono carries prose, structure, and code; paper printout by day, amber-phosphor terminal by night; markdown heading markers, dashed perforation rules, a status-line footer. CSS-only via contract 1.1, same token API as `default`. (#134)
- New official theme `porcelain`, the first CSS-only theme (0.6.0 catalog, clinical lane): glazed-ceramic ground as a full light-dark world, self-hosted Literata latin subset (upright + italic, 72 KB, OFL), sage accent, hairline understatement. Ships a manifest, a stylesheet, and two font files - templates inherit from the default theme via contract 1.1. Same token API as `default`, so overrides port across. (#133)
- A `?theme=light|dark` query param forces that rendition for the view without touching the stored preference - shareable forced-theme links, and what the new screenshot harness (`scripts/theme_shots.mjs`: standard page set, two true-CSS-pixel viewports via CDP emulation, both renditions, print PDF of `/cv/`) drives for theme QA. (#132)
- Template inheritance (theme contract 1.1): a theme may declare `inherit_templates: true` and skip shipping template files - unshipped templates render with the default theme's copies, `theme.list` marks them `inherited (framework)`, and `gen.theme --from` materialises them into forks. CSS-only themes are now a manifest, a stylesheet, and fonts. (#131)

### Changed
- Fonts load without a flash: every `.woff2` a theme ships under `assets/fonts/` is preloaded from the framework-owned head (so CSS-only themes get it without a layout), the official themes switch to `font-display: block`, and each family gains a metric-matched local fallback face (`size-adjust` plus ascent, descent and line-gap overrides computed from the font) so a swap after a slow fetch moves nothing. On a throttled 1.5 Mbps link every face lands before first paint and layout shift stays under 0.01. (#140)

### Fixed
- Theme personality CSS is back inside the `theme` cascade layer in all thirty themes (the sections appended after the layer had escaped it, in the official pair too), restoring the ladder's guarantee that a site's unlayered `custom.css` and token overrides win by declaration order, never by specificity. A search-chrome reset in every non-official theme keeps the field and results on the prose face regardless of the nav's display styling. (#142)
- Root-absolute links and sources written in markdown (`[blog](/blog/)`, `<img src="/images/x.png">`) now move under `base_path` like every other internal URL; they used to 404 on a project-pages site. `cherry check` now reports a root-absolute link that escapes the base path as `broken-link` instead of skipping it as external. External (`https://`, `//host/`) URLs are untouched as before. (#140)
- Phone search: the field no longer zooms the page on focus on iOS in any theme (the 16px coarse-pointer rule lost the cascade); constellation's results panel no longer paints under the page, and its field is a pill on its own row. Halftone squares its code block header, copy button, and the rest of its chrome, and the block wears one frame instead of two. (#140)

## [0.5.0] — 2026-08-22

### Added
- Built-in help: bare `cherry`, `cherry help`, and `cherry --help` list every verb with a one-line summary; `cherry help VERB` and `cherry VERB --help`/`-h` print the verb's full doc, rendered from the same single-sourced text as the mix task docs and the agent skill. Help prints to stdout and exits 0 — bare `cherry` previously exited 2 with "no command given". (#105)
- The cherrybomb theme ships Noto Sans Mono for code: a 32 KB latin-subset variable woff2, self-hosted in the theme's assets and leading `--font-mono` — zero third-party requests. The default theme keeps its zero-byte system stack. (#106)

### Changed
- Copy buttons on code blocks are icon-only 28 px squares (words moved to `aria-label`), and on touch screens the code block reserves its top corner so the always-visible button never covers code. (#106)
- The profile is now one page with two modes: `/cv/` renders the cv-curated entries in a Stack Overflow Careers-style two-column layout (story-linked tag pills, skills derived from the whole history in the sidebar) and is the default; the full dated timeline lives at `/cv/timeline/` with a view switcher linking the two modes. `/portfolio/` ships as a redirect to its successor so old links keep working, and the nav carries one profile entry (CV when public, otherwise Portfolio pointing at the timeline). The demo site gains a `portfolio.yaml`, turning its CV on. (#96)

## [0.4.1] — 2026-08-22

### Fixed
- `cherry serve` no longer lets abandoned live-reload streams pile up: the injected client closes its EventSource on `pagehide` (and reloads a page restored from the back/forward cache), and the SSE handler sends a comment-frame heartbeat every 15 s so a vanished browser is noticed and its socket released. Six parked streams used to exhaust the browser's per-host connection pool, stalling the next navigation for close to a minute. (#97)

## [0.4.0] — 2026-08-21

### Fixed
- `cherry serve` honours `base_path`: the site serves under its prefix exactly as production will (banner URL included), the bare root redirects there, and an unprefixed path that would 404 on the real host now 404s in dev too — previously a `base_path` site served styleless because every emitted asset URL pointed at the prefix the dev server ignored. (#92)

### Added
- `cherry gen.action --host cloudflare`: first-class Cloudflare deploys via Workers static assets — writes a `wrangler.jsonc` (no Worker script; `_site/` as assets with `404.html` wired up, Worker named by `--name` or a slug of the site title) plus `.github/workflows/cloudflare.yml`, which builds with the pinned cherry action and ships with `wrangler deploy`. `_headers`/`_redirects` files pass through `static/` verbatim, so Cloudflare's header and redirect rules work with no new config. (#91)

## [0.3.0] — 2026-08-21

### Added
- `cherry serve` honours the `PORT` environment variable when `--port` is absent (explicit flag still wins; malformed values fall back to 4000) — what proxy runners and PaaS-style tooling hand out. (#83)
- `cherry serve --name NAME` registers the bound port with a running [cherrypicker](https://github.com/holsee/cherrypicker) daemon, so the site also answers at a stable `http://NAME.localhost` URL. Zero-cost stdlib client; no daemon running means the port URL as ever, never a failed serve. (#84)

### Fixed
- Template overlays work for sites using Cherry as a hex dependency: the official themes live under the site's own `_build` there, which the site-local check mistook for a theme living in the site, silently disabling every overlay. Built-in themes are now never site-local, wherever they sit on disk. (#86)

## [0.2.0] — 2026-08-20

### Added
- `cherry serve --verbose`: a request log at last — method, path, status, and response time per line, SSE reload subscribers included. (#62)
- `cherry new PATH`: the binary lane can finally scaffold — config, first post, pages, `AGENTS.md`, and the `.claude` publish skill, all speaking `cherry <verb>`. Refuses a non-empty directory; the title humanizes from the directory name. Deliberately no `mix cherry.new` twin in core: the `cherry_new` archive owns that name (and adds the mix project files), so both install lanes coexist. (#57)
- HEEx templates: the three-level lookup now accepts `<name>.html.heex` beside `<name>.html.eex`, and HEEx wins at the same level. Interpolation escapes by default (`raw/1` is the explicit door), `:for`/`:if` and `<.component>` calls work, and a theme-root `components.exs` (`use Phoenix.Component`, runtime-compiled like every `.exs` escape hatch, binary included) defines function components for that theme's templates. A `.heex` overlay is `rewritten` in `theme.diff` — owned outright, since no three-way merge against an EEx upstream is possible — and `theme.eject` refuses to write an `.eex` copy a rewrite would shadow. Malformed templates fail the build with file, line:column, and a caret. Official themes stay EEx. (#54)
- Content components, framework-level so theme swaps survive them: `::figure{src alt caption}` (alt required), `::video{youtube title}` — a facade link that makes zero third-party requests until clicked, upgraded in place to a youtube-nocookie embed by a new ~500-byte island, or `src=` for a native local player — and `:::note{title} … :::` containers for the five alert types, in the remark-directive syntax Docusaurus and VitePress authors already know. Directives inside code fences are shown, not expanded; misuse never breaks a build — the line stays visible and `cherry check` gains a `component` rule naming the file, line, and problem. (#53)
- The customization ladder's middle rungs are real: `tokens: ["--color-accent": "#7c3aed"]` in `cherry.exs` overrides any token the theme's manifest declares (a typo errors with the nearest real name), and `assets/custom.css` loads last, always. Both ride the framework-owned head, so every theme honors them without cooperating; official theme CSS now lives in `@layer theme`, so site overrides win by cascade-layer rules rather than specificity fights. (#51)
- `cherry theme.tokens`: the theme's styling API as a command — every token with its default, doc, and any site override, merged. (#51)
- `cherry config tokens.NAME VALUE`: token overrides written from the CLI, the one structured setting `config` edits — entries are distinctive enough to rewrite surgically, and the name is validated against the theme manifest before the file is touched. (#51)

### Fixed
- `cherry serve` listens on IPv6 as well as IPv4 (a second v6-only listener on the same port — Windows cannot unset ipv6_v6only, so one dual-stack socket is not portable). `localhost` no longer stalls on hosts that resolve it to `::1` first; hosts without IPv6 keep the IPv4 listener alone. (#62)
- Mobile tap targets: nav, footer, and post-meta links in both official themes now meet the WCAG 2.5.8 24px floor (hit area grows via padding + negative margin, zero layout shift), and the search input holds 16px at coarse pointers so iOS Safari never zooms on focus. (#55)
- `theme.which` arrowed both the `.heex` rewrite and the shadowed `.eex` twin with `← renders`; only the file that actually renders gets the arrow now, and the JSON envelope carries it as `renders`. `theme.diff` reported that shadowed `.eex` as `current`; it is now `shadowed`, with `check` treating it as inert. (#56)

### Changed
- `cherry new` and `mix cherry.new` scaffold `search: "cherry"` — full-text search on from the first build, no Node anywhere; delete the line to opt out. (#61)
- Both official themes moved to `light-dark()` tokens: every color token is one pair instead of three synchronized blocks (light, dark-via-media, dark-via-toggle), the toggle forces a rendition by flipping `color-scheme` alone, and printing from a forced-dark page now gets the full light rendition — syntax palette included, which the old print block could not reach. Engines without `light-dark()` get the complete light rendition (the pairs live behind `@supports`) and the toggle stays hidden there. Token manifests now declare the pair (`default:` light, `dark:`), gate-enforced against the CSS, and `theme.tokens`/`theme.list` report it. (#52)

## [0.1.0] — 2026-08-17

The first stable release. The entries here are what landed since rc.3; the
three release-candidate sections below record the rest of the road to 0.1.0.

### Added
- `demo/GUIDE.md` and the site it builds (`demo/site`): a CLI-only walkthrough from an empty directory to a deployed site, every command run and its real output pasted in, gated by a test that fails if the guide shows a verb the CLI does not have or the site it describes stops building clean. (#48)
- `cherry config` reads and writes `cherry.exs`, closing the last gap in the CLI-only loop: a scaffolded theme can now be activated (`cherry config theme themes/NAME`) without an editor. Writes rewrite only the changed value — comments and layout survive — are validated by reloading the site, and roll back if the value is rejected. Structured settings like `nav:` are refused rather than reformatted. (#47)
- `cherry version` reports the git revision it was compiled from, so a build from a branch is no longer indistinguishable from the release it was branched from. `null` for a build compiled from hex. (#47)
- `check` gains `empty-body` and `unfilled-field`: a published post with no prose, or frontmatter still holding the empty string a generator wrote, no longer passes silently. (#47)
- `search: "cherry"`, a built-in search engine that needs no Node: the index is an inverted list built in-process from the parsed documents and emitted as `search/index.json`, ranked in the browser by a ~2 kB island that ships from `priv/search/` so any theme gets it. Pagefind stays available as `search: "pagefind"` for sites that want it and can afford `npx` on the build machine. (#46)

### Changed
- The `@search` template assign carries the configured engine (`"cherry"`, `"pagefind"`, `nil`) instead of a boolean, since the two engines need different markup; `<%= if @search do %>` still reads as "search is on". (#46)

### Fixed
- `cherry serve` claimed live reload on filesystems that never deliver change events (a Docker bind mount from a Windows or macOS host, a network share): the watcher started, the banner promised reloads, and no edit ever rebuilt. Serve now proves the watcher works with a probe in the content directory before believing it, and degrades with a warning naming the likely cause when it does not. Probing the watch root would not do — that mount delivers events for the root and none for its subdirectories, which is exactly where content lives. (#47)
- `cherry serve` logged `Header timestamp couldn't be fetched from ETS cache` on every single response: Bandit was started as a bare child spec, leaving the clock table its own application owns unstarted. (#47)
- `cherry upgrade --check` exited 1 when only prereleases existed. "Nothing stable yet" is an answer, not a failure; it now exits 0 with `status: "no_stable_release"`. The upgrade itself still refuses. (#47)
- `copy-code.ts` was missing the `export {}` that keeps an island out of the shared TypeScript global scope, so its top-level names leaked and collided with any new island's. (#46)
- `cherry gen.theme` produced a theme that `cherry check --strict` immediately rejected: because overlays are keyed by theme name under `themes/`, a site-local theme resolved its own templates as untracked overlays of itself and every one was reported as drift. Overlays now only exist relative to an installed theme; `theme.eject` refuses a site-local theme instead of writing onto it. (#45)

## [0.1.0-rc.3] — 2026-08-15

### Fixed
- `cherry serve` no longer crashes when no file-watcher backend is available (inotify-tools missing on Linux, the common case in containers and CI): the site serves without live reload, a warning names the platform's remedy, the banner says so, and the envelope carries `live_reload: false`. (#42)
- The standalone binary forces UTF-8 filename and terminal encoding (`rel/vm.args.eex`), so latin1-locale containers stop warning on boot and mangling the banner. (#42)

### Changed
- The release workflow's per-target smoke test now actually serves: scaffold, background `serve --port 0` with no TTY, HTTP probe, and a process-still-alive check on all five targets — real macOS serve coverage without owning a Mac, and the class of bug rc.1 shipped can no longer reach a release. (#42)

## [0.1.0-rc.2] — 2026-08-15

### Fixed
- The standalone binary exited the moment `cherry serve` printed its banner (`Cherry.Binary` halted unconditionally after every command); blocking verbs now hold the VM open, single-sourced in `Cherry.CLI.Registry.blocking?/1` so the binary and the mix task cannot drift. (#39)
- `install.sh` / `install.ps1` downloaded GitHub's HTML 404 page while only prereleases exist (`releases/latest` never resolves a prerelease); both installers now resolve the tag via the releases API and fall back to the newest release of any kind. (#39)
- `cherry publish` accepts the bare slug `gen.post` returns in its envelope; an ambiguous slug is a usage error naming the candidates, and the path form still works. (#39)
- `cherry check` no longer reports protocol-relative URLs (`//host/…`) as broken internal links; they are external by definition. (#39)
- Hex package hygiene ahead of the first real publish: dialyzer PLT caches no longer ship in the tarball; hexdocs carry the CherryBomb marks (sidebar logo plus the lockup bundled into the README via ExDoc assets, so docs are self-contained) and a grouped module sidebar; README gains a "Use from Elixir" section and reality-checked Status; `cherry.new` scaffolds depend on the hex release matching the installer instead of the develop branch, and the `cherry_new` hex page gets a README. (#34, #35)
- Pagefind search drawer rendered in document flow inside the nav, pushing the whole page down with an off-centre results column, a dead thumbnail gutter, browser-yellow highlight marks, and a search input that overflowed the viewport on mobile. Both themes now anchor the drawer as a token-themed overlay panel under the input (`showImages: false`, internal scroll), and the header wraps at 44rem so search gets a full-width row on small screens. (#30)

### Changed
- Serve docs, the skill, and the authoring guide now cover `--port`, recommending `--port 0` (bind a free ephemeral port, reported in the envelope) for scripts, CI, and agents; the skill also teaches publish-by-slug. (#39)
- `gen.action` workflows pin the build action to the release tag of the running cherry (`holsee/cherry/action@v<version>`) instead of `@develop`, so generated pipelines stop tracking a moving ref; the action README example pins to `v0.1.0-rc.1` and the TODO is gone. (#33)
- CherryBomb brand assets (logo, mascot, wordmark, and all repo derivatives) are excluded from the MIT/Apache-2.0 dual license: `assets/LICENSE` reserves them while permitting in-product display and nominative use; the hex package ships the notice alongside the theme's nav mark. (#30)
- Site prose voice pass: no em dashes anywhere on cherrybomb.dev, all JSON code blocks fully pretty-printed. (#30)

### Added
- "Using Cherry from Elixir" guide on cherrybomb.dev: cherry_new scaffolding, the full mix task parity table, the library API (`Cherry.build/1` / `Cherry.check/1` with struct-accurate examples), and when to pick binary vs package; README gains the same cherry_new story, the task table, and standard badges (hex version, hexdocs, CI, license) on both packages. (#37)
- Copy buttons on code blocks: a new `copy-code.js` island in both official themes puts a hover-revealed (always visible on touch) copy button on every `pre` and any `data-copy` element, clipboard-API based, token-styled, print-hidden; islands are now compiled into both themes by `npm run build` and a sync test pins the copies byte-identical. (#31)
- Search keyboard shortcut: Ctrl+K / ⌘K focuses the Pagefind input in both themes, and the placeholder advertises it per-platform. (#31)
- `nav:` entries accept `position: :start | :end` (default `:end`), so configured items can lead the nav ahead of the built-ins; cherrybomb.dev puts Guides before Blog. (#31)
- Landing page pitch pass: a "Not just a blog" section covering the portfolio timeline, story pages, and the JSON-Resume-backed `/cv`, plus a brush-checked top-ten feature list (AI-agent-friendly CLI + skill included) replacing the poster wall. (#31)
- cherrybomb.dev, the real thing: full brand pass on the dogfood site — cherrybomb theme + Pagefind search enabled, brand-derived favicon/apple-touch/OG-card/nav-mark assets, a poster-wall landing page with real CLI envelopes, and a core guide set (quick-start, authoring loop, verifier, themes, deploy, scripting & agents, upgrade), all `check --strict` clean; Pages workflow gains the Node step Pagefind needs. (#29)
- Site enablers the dogfood exposed: heading anchor links + GitHub-style `> [!NOTE]` alerts (mdex, styled in both themes with zero new tokens), favicon-by-convention (`static/favicon.ico|favicon.svg|apple-touch-icon.png` → head links via `Cherry.Site.Icons`), `nav:` config for custom nav items (broken-link-checked), a `page_class` body class per section, and `twitter:card` upgrading to `summary_large_image` when `social_image` is set. (#28)
- The cherry agent skill (`skills/cherry/`, fizzy-cli layout): a canonical `SKILL.md` teaching agents the safe-start checks, the author → build → check → publish → deploy loop, structured-diagnostic handling, provenance-based theme management, and binary self-update — plus a command reference generated from the CLI verb registry and CI-gated against drift (`mix run scripts/regen_skill.exs`), with `.claude/skills/` and `.agents/skills/` pointer shims. New verbs cannot land without the skill teaching them. (#27)
- `cherry upgrade`: first-class self-update for the standalone binary (ADR 0007) — resolves the latest stable GitHub release (or `--version` for any tag, prereleases included), verifies this platform's asset against `SHA256SUMS`, and swaps the running executable rustup-style; `--check` reports without touching anything and works under mix too. Zero new deps (`:httpc` + OS trust store). (#26)

## [0.1.0-rc.1] — 2026-08-14

### Added
- Standalone binary + release pipeline (ADR 0007): Burrito packaging (`Cherry.Binary` boots the CLI seam only in `CHERRY_RELEASE` builds), tag-gated release workflow with a five-target native-runner matrix, per-binary smoke tests, `SHA256SUMS` + build-provenance attestation, prerelease-aware publishing, and real checksum-verifying `install.sh` / `install.ps1` served from cherrybomb.dev; `workflow_dispatch` runs the whole matrix as a publish-nothing dry run. (#24)
- Published build action (`holsee/cherry/action`): composite GitHub Action doing toolchain setup, caching, `cherry.build`, and `cherry.check` (strict by default) in one `uses:` step — GH Pages users never touch Elixir locally; `gen.action` workflows now wrap it, and CI exercises the action against a fresh `cherry.new` site on both OSes. (#23)
- Optional Pagefind search: `search: "pagefind"` in `cherry.exs` — the new Post pipeline stage indexes the emitted site (`npx pagefind`), both official themes grow a token-styled search island only when enabled, and default builds stay byte-identical and dependency-free. (#22)
- `mix cherry.new PATH` (the `cherry_new` installer, `installer/`): scaffolds an agent-ready site — content dirs, config (including the Lumis NIF selection consumers must carry), first post, `AGENTS.md` documenting the operate loop, and a `.claude/skills/publish` skill; CI dogfoods a generated site with `build` + `check --strict` against every commit. (#21)
- `cherry theme.diff`: managed drift — every overlay's three-way status against the installed theme (`current` / `auto_updatable` / `conflict` / `untracked`), `--apply` re-ejects auto-updatable ones with fresh provenance, and `cherry check` warns on stale or untracked overlays. Frozen theme copies, answered. (#20)
- JSON Feed: `feed.json` (jsonfeed.org 1.1) alongside Atom with a discovery `<link>` on every page; `cherry check` now verifies it too. (#19)
- The machine surface: every content route now carries an `index.md` markdown mirror alongside its `index.html` (posts, pages, blog index, tag pages, portfolio timeline, stories, CV), plus a generated `/llms.txt` per the llmstxt.org convention with absolute links to the mirrors; unlisted pages keep their mirrors but stay out of `llms.txt`, and mirrors never leak into the sitemap or feed. (#18)
- `--json` contract audit: error envelopes now carry structured `details` (a failing `check --strict --json` returns its diagnostics machine-readably, not just prose), and a registry-complete contract test proves every verb's success and error envelopes decode — new verbs cannot land without envelope coverage. (#17)
- `cherry check`: the verifier — builds in memory (writes nothing) and reports structured diagnostics (broken internal links, missing descriptions, images without alt text, duplicate titles, Atom feed sanity); errors exit 1, `--strict` promotes warnings, `--json` feeds the agent's build → check → fix loop. (#16)
- The cherrybomb theme: second official theme carrying the brand — neon night wall by dark, poster paper by day, brush-stroke title, glowing code blocks — same contract and token API as the default, proving the swap is real; `cherry gen.theme NAME [--from THEME]` scaffolds an editable site-local copy. (#15)
- `cherry gen.project` and `cherry gen.talk`: portfolio scaffolds with valid frontmatter (build-clean as generated), duplicate refusal, `--json` for agents. (#14)
- The CV view: `/cv/` as an employer-shaped projection of the portfolio (cv: curation, weight ordering, curated bullets), evidence-backed skills derived from merged calendar spans and linked to story pages, `/cv.json` in JSON Resume format, print-first stylesheet (black-on-white, no chrome, no split entries), and `visibility: public | unlisted | off` with noindex/sitemap handling. (#13)
- Portfolio views: `/portfolio/` timeline (profile header, year-railed entries, open source as standing roles), `/story/:tag/` pages cross-linking positions/projects/talks/OSS/education with blog posts on one tag, `Person` JSON-LD, nav that knows the portfolio exists, and blog tag pages linking to their story. (#12)
- Portfolio data layer: typed collections (`portfolio/positions`, `projects`, `talks`, `oss`, `education`) with introspectable schemas, `portfolio.yaml` profile, `cv:` curation blocks, and domain structs (`Position`, `Project`, `Talk`, `OpenSource`, `Education`, `Profile`, `CV`, `Link`) materialised via `Cherry.Portfolio.from_build/1`; entries are data-only (no page routes). (#11)
- cherrybomb.dev deploy: Pages workflow building `example/` on push to main with CNAME; reserved `/install.sh` and `/install.ps1` installer paths (ADR 0007). (#10)
- `cherry gen.action`: generates the GitHub Pages deploy workflow (build → upload → deploy, `.nojekyll`, CNAME for custom domains); `example/` dogfood site (the future cherrybomb.dev) now builds in every CI run. (#9)
- Default-on SEO and machine surface: canonical/Open Graph/JSON-LD head block on every page, Atom `feed.xml`, `sitemap.xml`, `robots.txt`; `base_path` support so every emitted URL works under GitHub project pages, proven by a base-path matrix test. (#8)
- Authoring loop: `cherry gen.post`, `cherry publish`, and `cherry serve` (Bandit + watcher + SSE live reload, drafts included). (#7)
- Default theme design: dual light/dark token palettes, class-linked syntax highlighting colored by theme tokens, no-flash theme toggle island (TS), token-discipline tests. (#6)
- Theme contract v1: `theme.exs` manifest, three-level lookup, `theme.list`/`theme.which`/`theme.eject` with provenance; default theme renders posts, blog index, tag pages, 404. (#5)
- Typed collections: posts + pages with introspectable schemas (`mix cherry.schema`), YAML frontmatter, MDEx GFM rendering, drafts/future filtering. (#4)
- Build pipeline (load→validate→transform→layout→emit), `cherry.exs` site config, `mix cherry.build`, golden-fixture harness, determinism gate. (#3)
- `Cherry.CLI.run/1` seam with verb registry, `--json` envelopes, stable exit codes; `mix cherry.version` tracer. (#2)
- Library skeleton with `mix precommit` gate, TS toolchain, and CI on ubuntu + windows. (#1)
- Project constitution (AGENTS.md), design doc (DESIGN.md), ADRs 0001–0006, backlog.
- Dual MIT / Apache-2.0 license.
- End-state README with the Cherrybomb identity.
- Devcontainer reference environment (Elixir 1.20.2 / OTP 28 / Node 22, pinned).
- Minimal 0.0.1 package stub to claim `cherry` on Hex (published).
- Portfolio dual-view design: Careers-style timeline + `/cv/` web CV, both
  projections of one dataset (DESIGN.md §4).

### Fixed
- Date ordering everywhere dates entered sort keys: `%Date{}` structs term-compare field-alphabetically (day before year), so feeds, the blog index, tag pages, the timeline, and skills could order Jan 15 above Feb 1; all sort keys now go through `Date.to_erl/1`. (#19)
- Byte-determinism of emitted JSON: atom-keyed map iteration follows atom-creation order and varies between VM runs, so `JSON.encode!` output was not reproducible; `feed.json` and `cv.json` now encode via `Cherry.StableJSON` with sorted object keys (ADR 0005). (#19)
