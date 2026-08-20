---
title: Why Cherry exists
description: I used to run my blog on Octopress. Cherry is what I wanted it to become, an old-school static site generator ready for the agentic era.
tags:
  - design
  - release
---
Cherry 0.1.0 went stable this week, so this feels like the right moment to write down why it exists at all.

## I used to use Octopress

If you were around in 2011, you remember the feeling. A blog that was *yours*, plain files you could reason about, a hacker's toolchain you could bend, `rake new_post` and push. I ran my blog on it for years, and I loved it the way you love a good workshop: everything within reach, everything modifiable.

And then it had these problems, and they were fatal.

**Customising it froze you in time.** Your site lived inside the framework checkout, so the moment you touched one theme file you had silently forked the whole thing. Every upstream fix, every improvement, walled off forever. Most Octopress blogs died of exactly that, mine included: not deleted, just stranded on a version of the world from the day you first changed the header.

**The toolchain rotted underneath it.** Ruby versions, gemsets, a `bundle install` that worked on the old laptop and not the new one. The site was static, but the ability to build it was anything but.

**And nothing ever checked your work.** A broken link, a missing description, an image without alt text: production found those, or nobody did.

## My fresh ideas

Cherry is what I wanted Octopress to become, built now, knowing what we know. Going in, I had a short list of convictions that I refused to trade away.

**A build should be a function.** Same tree in, same bytes out, every time, on every machine. Cherry's CI double-builds its fixture sites on every commit and fails if one byte differs. No timestamps in output, no "generated at" footers, no map ordering leaking into HTML. It sounds like discipline for its own sake until you feel it: deploy diffs that mean something, caches that work, and the quiet confidence that when the output changed, *you* changed it.

**The verifier should be the product.** `cherry check` builds your entire site in memory, writes nothing, and reports problems as structured diagnostics, each naming the file that would fix it:

```text
[error] content/pages/reading.md: broken-link — links to /guides/pruning/, which this build does not emit
```

Schema-validated frontmatter, broken links, missing alt text, duplicate titles, scaffold fields nobody filled in. The generated deploy workflow runs `check --strict` before it builds, so the class of mistake that used to live on production cannot arrive there.

**The toolchain should be one file.** Cherry ships as a single self-contained executable with the whole BEAM inside, thanks to [Burrito](https://github.com/burrito-elixir/burrito). `curl | sh` and you have the builder, the verifier, the dev server, the theme system, and the search indexer, on any machine, forever. `cherry upgrade` swaps the binary in place, checksum-verified. Elixir folk take the hex package instead and get every verb as a mix task; both lanes build byte-identical sites, by construction and by test.

**And customisation should never cost you the upgrade path.** The Octopress failure mode got a system of its own. Themes expose **tokens** as their public styling API, so changing your accent colour is one config line, not a fork. When you do need to own a template, `theme.eject` records provenance (theme, version, content hash), and `theme.diff` gives you a three-way answer after every upgrade: `current`, `auto_updatable`, or `conflict`, with `--apply` for the safe case. Your customisation and the upstream's progress stop being enemies.

## The same old-school generator, ready for the agentic era

Here is the part that was not on anyone's list in 2011. The plain-files, plain-commands shape that made Octopress lovable turns out to be exactly the shape a coding agent needs, if you finish the thought.

So Cherry finishes it. Every verb takes `--json` and returns one envelope shape with honest exit codes. `cherry schema posts` answers "what does a valid file look like" before an agent writes a single line. Every build emits `llms.txt` and a markdown mirror beside every page, so the published site is legible without a DOM parser. The scaffold writes an `AGENTS.md` that teaches the whole loop to whatever agent you point at the repo.

None of that was bolted on afterwards. The CLI was designed against one question: could a machine drive this loop unattended, and would a human enjoy the same interface? The answer to both is yes, and it is the same interface. Your blog can be a thing you write by hand on a Sunday, a thing your agent tends while you sleep, or both in the same week, and Cherry cannot tell the difference.

That is 0.1.0: the workshop I missed, with the failure modes engineered out and the doors opened for what comes next. The [quick-start](/guides/quick-start/) is fifteen minutes if you want the feeling rather than the philosophy, and the styling and template rethink is already brewing in [the next post](/what-building-0-2-0-taught-us/).
