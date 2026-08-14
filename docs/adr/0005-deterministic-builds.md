# ADR 0005: Deterministic builds are a contract

**Status:** Accepted — 2026-08-14

## Context
Agents verifying their own work, CI caching, and golden-file testing all depend on
builds being reproducible. Most SSGs leak wall-clock timestamps, random IDs, or
map-iteration order into output.

## Decision
Same inputs → byte-identical `_site/`, guaranteed by a permanent test in the suite
(build a fixture twice, compare trees). No build-time timestamps except where content
demands them (dates come from frontmatter, not the clock). Collections sort on
explicit keys, never map order.

## Consequences
The determinism gate lives in `mix precommit` forever. Golden tests stay meaningful.
Any feature that wants "now" (e.g. feed `updated`) must derive it from content.
