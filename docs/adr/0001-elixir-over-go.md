# ADR 0001: Elixir over Go

**Status:** Accepted — 2026-08-14

## Context
Cherry needs a host language. Go offers single-binary distribution (Hugo's territory);
Elixir offers mix tasks, EEx, MDEx (Rust NIF, ~400 iter/ms), parallel rendering, and a
maintainer who enjoys it.

## Decision
Elixir. Distribution friction is neutralized by: the `cherry_new` archive, a published
GitHub Action (no local toolchain for Pages users), and a Burrito standalone binary
(ADR 0006).

## Consequences
Users wanting compiled site-local extensions need Elixir installed (project mode).
A Go Cherry would have been "Hugo with different opinions" — undifferentiated.
