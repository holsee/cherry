# ADR 0006: One CLI seam behind mix tasks and the binary

**Status:** Accepted — 2026-08-14

## Context
Cherry ships two frontends: mix tasks (project mode) and a Burrito standalone binary
(binary mode, Phase 3). Two frontends that each implement behaviour will drift.

## Decision
All behaviour lives behind `Cherry.CLI.run/1`. Mix tasks and the binary dispatcher are
thin wrappers — verb for verb, flag for flag. The seam is built in Phase 1 even though
the binary ships in Phase 3. Every command supports `--json` from birth; exit codes
are documented and stable.

## Consequences
The binary is cheap when its time comes, and can never disagree with the mix tasks.
Task docs single-source from the task modules; the CLI help is generated from the
same definitions.
