# ADR 0003: Typed content collections with introspectable schemas

**Status:** Accepted — 2026-08-14

## Context
Frontmatter errors in most SSGs surface as broken output or silent defaults. Astro
proved schema-validated collections catch this at build time with file+field errors.
Agents writing content need to know what "valid" means before writing.

## Decision
Every content type is a collection: directory + NimbleOptions-style schema + routing
rules. Built-ins: `pages`, `posts`, `portfolio/*`. Users define custom collections in
config. Schemas are introspectable via `mix cherry.schema <collection> --json`.
Frontmatter is YAML.

## Consequences
Build fails loudly and precisely on bad frontmatter. The schema is simultaneously
validation, documentation, and the agent contract. Portfolio entries share one tag
taxonomy with posts — cross-linking is structural.
