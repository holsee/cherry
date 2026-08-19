# Staying current

# Staying current

The standalone binary updates itself. No package manager required, nothing to re-download by hand.

## Check first

```sh
cherry upgrade --check --json
```

```json
{
  "ok": true,
  "command": "upgrade",
  "data": {
    "current": "0.1.0-rc.1",
    "target": "v0.2.0",
    "asset": "cherry-linux-x86_64",
    "status": "outdated"
  }
}
```

`--check` touches nothing and works everywhere, even under mix, where the swap itself is refused (library users upgrade with `mix deps.update cherry`, and the error says exactly that).

## Upgrade

```sh
cherry upgrade
```

What happens, in order:

1. Resolves the **latest stable** GitHub release; prereleases never arrive uninvited.
2. Downloads this platform's binary from the release.
3. **Verifies it against the release's `SHA256SUMS`.** Any mismatch or missing entry aborts with the current binary untouched. There is no override flag, by design.
4. Swaps the executable in place: write beside, rename out, rename in. The running image is never overwritten.

```text
upgraded cherry 0.1.0-rc.1 → 0.2.0
```

> [!NOTE]
> Tracking a release candidate on purpose? `cherry upgrade --version v0.2.0-rc.1` targets any tag, prereleases included.

> [!WARNING]
> On Windows the replaced executable lingers beside the new one as `cherry.exe.old`, because the OS keeps the running image locked. It's harmless, safe to delete, and the next upgrade reuses it.

## Provenance all the way down

The same guarantees hold at install time: `install.sh` and `install.ps1` verify their download against `SHA256SUMS` before installing, and every release binary carries GitHub build-provenance attestation. The binary you run is, verifiably, the binary CI built from the tag.
