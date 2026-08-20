# Releasing Cherry

The full checklist for cutting `vX.Y.Z`. Every step, every release — the
hex publish at the end is part of the release, not an afterthought: the
site links hexdocs.pm/cherry and the `cherry_new` archive, and both 404
until the packages are up to date.

## 1. Release branch (off develop)

- [ ] `CHANGELOG.md`: retitle `[Unreleased]` to `[X.Y.Z] — YYYY-MM-DD`;
      every user-facing PR since the last release has a one-liner.
- [ ] Bump `@version` in `mix.exs` **and** `installer/mix.exs` (the
      installer's scaffolded `{:cherry, "~> X.Y.Z"}` dep pin follows the
      installer version automatically).
- [ ] `action/README.md`: example pin `holsee/cherry/action@vX.Y.Z`.
- [ ] `README.md`: status blurb and any `{:cherry, "~> …"}` examples.
- [ ] Site content: `guides/elixir.md` dep line; refresh version
      transcripts (`guides/quick-start.md`, `docs/cli.md`) by actually
      running `cherry version` against the bumped tree — outputs on the
      site are never invented.
- [ ] `mix ci` green; PR the release branch into develop and merge.

## 2. Ship

- [ ] PR develop → main. **Merging it deploys cherrybomb.dev**
      (pages.yml fires on main push) — the site is signed off before
      this point.
- [ ] Tag the merge commit: `git tag vX.Y.Z <sha> && git push origin
      vX.Y.Z`. The Release workflow gates on `mix precommit`, builds the
      five native binaries, and publishes the GitHub release with
      `SHA256SUMS` and provenance attestation. Prerelease tags
      (`vX.Y.Z-rc.N`) publish as prereleases and never become "latest".
- [ ] Verify: the live site, the release assets, and a real
      `cherry upgrade` from the previous version.

## 3. Hex publish (manual — needs your OTP)

Interactive by design: hex prompts for a one-time password, so this is
run by a human, from the tag, once the GitHub release is out.

```sh
git checkout vX.Y.Z

# main package + hexdocs
mix deps.get
mix hex.publish

# the cherry_new scaffolding archive
cd installer
mix hex.publish
```

Rules:

- Publish as **yourself** — if hex offers an organization, the answer
  is always `[1] Yourself`, never an org.
- `mix hex.publish` shows the file list and metadata before asking for
  confirmation; read it. Docs build and publish to hexdocs.pm in the
  same step.
- On Windows, run with a host-local build root so the container's
  `_build` is untouched: `$env:MIX_BUILD_ROOT="$env:LOCALAPPDATA\cherry-build"`.
- [ ] Verify afterwards: https://hexdocs.pm/cherry resolves, and
      `mix archive.install hex cherry_new` pulls the new version.

## 4. Close out

- [ ] `git checkout develop` — day-to-day work never happens on main.
- [ ] Open the next milestone if it does not exist.
