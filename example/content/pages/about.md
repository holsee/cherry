---
title: About
description: Why Cherry exists, what it took from Octopress, and how this site is its own proof.
---
# About Cherry

Cherry is a static site generator for hackers: a modern take on Octopress, built in Elixir.

Octopress got two things right that the years buried: a blog you could reason about as plain files, and a hacker's toolchain you could bend. It got one thing fatally wrong: your site lived *inside* the framework checkout, so every customization froze you in time. Cherry inverts that: your site is a plain directory, the framework is a dependency (or a single binary), themes expose tokens as their styling API, and every template you take ownership of carries provenance so upgrades merge instead of fossilizing.

The second thesis: **everything answers in plain text**. Every command has a `--json` twin with stable exit codes, content collections publish their schemas, builds are byte-deterministic so diffs mean something, and every built page ships a markdown mirror plus [/llms.txt](/llms.txt). That makes the whole thing scriptable end to end. Paired with the shipped skill, it's also easy to hand to a coding agent when one helps run your site. The [scripting guide](/guides/agents/) shows the whole surface.

## This site is the dogfood

cherrybomb.dev is built by Cherry from the [example/ directory of Cherry's own repo](https://github.com/holsee/cherry/tree/develop/example) on every push: same pipeline, same checks (`cherry check --strict` gates every commit), same theme contract you get. If something here is broken, the build that shipped it failed its own tooling, and that's a bug worth [filing](https://github.com/holsee/cherry/issues).

Cherry ships as a [single binary](/guides/quick-start/) for macOS, Linux, and Windows, with checksum-verified installs, provenance-attested releases, and [self-updating](/guides/upgrade/). Elixir developers can use it as a library instead; the verbs are identical by construction.

Cherry's code is dual-licensed under MIT or Apache 2.0. The CherryBomb artwork (the mascot, logo, and icons on this site) is copyright holsee, all rights reserved, and isn't covered by either license; see [the brand assets license](https://github.com/holsee/cherry/blob/develop/assets/LICENSE) before reusing it.
