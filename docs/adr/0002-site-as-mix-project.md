# ADR 0002: Sites are thin mix projects; framework is a hex dep

**Status:** Accepted — 2026-08-14

## Context
Octopress 2.x put the user's blog *inside* the framework checkout; upgrades were merge
hell and the 3.0 rewrite killed the project. Hugo's opposite extreme (global binary +
config) sacrifices hackability.

## Decision
A Cherry site is a thin mix project depending on the `cherry` hex package (the Phoenix
model). Framework upgrades are a version bump. "Plugins" are plain Elixir modules in
the site repo hooking pipeline stages — no plugin API in v1. A **binary mode** exists
for non-Elixir users: content + config directory, extensibility via runtime-interpreted
`extensions/*.exs` (works identically in both modes).

## Consequences
Full hackability without a plugin API; upgradability without merges. Binary-mode sites
cannot use *compiled* site-local modules; converting to project mode = add `mix.exs`.
