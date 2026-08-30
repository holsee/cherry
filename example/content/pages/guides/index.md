---
title: Guides
description: Project-shaped guides for Cherry. Build a site, a portfolio with a CV, a theme of your own; then ship it and keep it current.
permalink: /guides/
---
# Guides

Every guide is a worked project: the commands, their real output, and what it means. Start at the top; branch when a project calls you.

## Build

<ul class="guide-list">
<li><a href="/guides/quick-start/">Your first site</a><p>Install the binary, cherry new, write a post, put it on the internet. Fifteen minutes, no Elixir required to run it.</p></li>
<li><a href="/guides/landing-page/">Pages and the landing page</a><p>Static pages from plain markdown files, and a landing page with a hero: raw HTML, theme classes, and custom.css.</p></li>
<li><a href="/guides/portfolio-and-cv/">Build a portfolio and host your CV</a><p>The developer timeline, story pages that cross-link your work by tag, and a print-ready CV with JSON Resume output.</p></li>
<li><a href="/guides/creating-a-theme/">Create a theme</a><p>Scaffold from an official theme, retune its tokens, restyle it, and rewrite a template in HEEx with function components.</p></li>
</ul>

## Write and verify

<ul class="guide-list">
<li><a href="/guides/authoring-loop/">The authoring loop</a><p>gen.post, edit, serve, publish, and the markdown mirrors every route ships.</p></li>
<li><a href="/guides/check/">The verifier</a><p>cherry check builds in memory and hands back structured diagnostics: the build, check, fix loop that keeps a site honest.</p></li>
<li><a href="/guides/themes/">Restyle without forking</a><p>Token overrides from one command, custom.css that always wins, ejects with provenance, and theme.diff so your look survives upgrades.</p></li>
</ul>

## Ship and run

<ul class="guide-list">
<li><a href="/guides/deploy/">Deploying to GitHub Pages</a><p>gen.action writes the workflow; Pages setup, custom domains, and project-page base paths.</p></li>
<li><a href="/guides/deploy-cloudflare/">Deploying to Cloudflare</a><p>gen.action --host cloudflare writes wrangler.jsonc and the workflow; Workers static assets, _headers and _redirects, custom domains.</p></li>
<li><a href="/guides/analytics/">Adding analytics</a><p>One key, four providers, and the rule that decides whether a consent banner ships at all: cookieless beacons, self-hosted instances, and a GA gate that actually gates.</p></li>
<li><a href="/guides/agents/">Scripting and agents</a><p>The --json envelope contract, schemas, llms.txt, and markdown mirrors, from jq one-liners to the shipped agent skill.</p></li>
<li><a href="/guides/elixir/">Using Cherry from Elixir</a><p>The hex package behind the binary: cherry_new scaffolding, mix task parity, and the library API for custom tooling.</p></li>
<li><a href="/guides/upgrade/">Staying current</a><p>cherry upgrade swaps the binary in place, checksum-verified against the release.</p></li>
</ul>

Looking for reference rather than a walkthrough? [The docs](/docs/) cover every verb, config key, and schema.
