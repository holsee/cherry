---
title: Docs
description: The Cherry reference. Every verb, every config key, every schema, with real output.
permalink: /docs/
---
## Documentation

The reference half of this site. The [guides](/guides/) walk you through building things; these pages tell you exactly what every surface does, with real output for all of it. Everything here is checked against the CLI that built this page.

### The tool

- [The CLI](/docs/cli/): all nineteen verbs, with their flags, envelopes, and exit codes.
- [Configuration](/docs/configuration/): `cherry.exs`, key by key, and how `cherry config` edits it without an editor.
- [The build pipeline](/docs/pipeline/): the nine stages between your markdown and `_site/`, and why builds are byte-deterministic.

### Content

- [The content model](/docs/content/): collections, frontmatter schemas, drafts, and the publish flow.
- [Content components](/docs/components/): figures, video facades, and callouts, from syntax to diagnostics.

### Appearance

- [Theming](/docs/theming/): the styling ladder, design tokens, `light-dark()` pairs, template overlays, provenance, and the HEEx lane.

### Integration

- [The machine surface](/docs/machine-surface/): JSON envelopes, `llms.txt`, markdown mirrors, and how agents operate a site.
- [Deploying](/docs/deploy/): GitHub Pages, custom domains, `base_path`, and what the generated workflow does.

:::note{title="Versions"}
These docs describe Cherry 0.2.0. Everything shown was run against the release; where a feature is newer than 0.1.0, the page says so.
:::
