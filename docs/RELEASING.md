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
run by a human, from the tag, once the GitHub release is out. The
`cherry-hex-home` docker volume holds the maintainer's hex auth, so the
dev container is the publish environment:

```sh
git checkout vX.Y.Z

# main package + hexdocs
MSYS_NO_PATHCONV=1 docker run --rm -it \
  -v "$(pwd -W):/workspace" \
  -v cherry-mix-home:/opt/mix -v cherry-hex-home:/opt/hex \
  -w /workspace cherry-dev mix hex.publish

# the cherry_new scaffolding archive (run `mix deps.get` in
# installer/ first if its dev-only ex_doc is not fetched)
MSYS_NO_PATHCONV=1 docker run --rm -it \
  -v "$(pwd -W):/workspace" \
  -v cherry-mix-home:/opt/mix -v cherry-hex-home:/opt/hex \
  -w /workspace/installer cherry-dev mix hex.publish
```

Rules:

- **Order matters: cherry before cherry_new.** Scaffolds depend on the
  matching cherry hex release — the requirement is derived at compile
  time from the installer's own version.
- Publish as **yourself** — at the owner prompt the answer is always
  `[1] Yourself`, never an organization.
- `mix hex.publish` shows the file list and metadata before asking for
  confirmation; read it (the `files:` list keeps dialyzer PLTs out of
  the package). Docs build and publish to hexdocs.pm in the same step.
- A hex release can only be reverted within one hour.
- [ ] Verify afterwards: https://hexdocs.pm/cherry resolves, and
      `mix archive.install hex cherry_new` pulls the new version.

## 4. Close out

- [ ] `git checkout develop` — day-to-day work never happens on main.
- [ ] Open the next milestone if it does not exist.
