# Codex sandbox in the hardened Dev Container

## Known-good baseline

As verified on 2026-09-03, Codex can create its Linux sandbox and can write inside
the workspace while writes outside it remain blocked.

The known-good components are:

- Base image: `mcr.microsoft.com/devcontainers/base:2.1.11-trixie`
- OS: Debian 13 (`trixie`)
- Bubblewrap: `0.11.0-2+deb13u1`
- Codex CLI: `0.153.0`
- Docker runtime hardening: the `x-hardening` anchor in
  `.devcontainer/compose.yaml`

The base image uses a patch-version tag intentionally. Do not replace it with the
moving `mcr.microsoft.com/devcontainers/base:debian` tag without testing the Codex
sandbox after rebuilding.

## Why Docker seccomp is unconfined

Codex on Linux uses bubblewrap (`bwrap`) to create an inner sandbox and installs
its own seccomp filter. Docker's default, outer seccomp policy can reject a
namespace or mount operation before bubblewrap finishes creating that sandbox.

For that reason, Compose contains:

```yaml
security_opt:
  - no-new-privileges
  - apparmor:docker-default
  - seccomp=unconfined
```

`seccomp=unconfined` disables only Docker's outer syscall filter. It does **not**:

- make the container privileged;
- restore capabilities removed by `cap_drop: [ALL, NET_RAW]`;
- disable `no-new-privileges`;
- disable the requested AppArmor policy; or
- disable the inner seccomp filter installed by Codex.

This is still a real trade-off: processes that are not running inside the Codex
sandbox no longer receive Docker's default seccomp filtering. The capability,
no-new-privileges, and AppArmor layers are therefore kept in place. The latest
verification showed `NoNewPrivs: 1`, `Seccomp: 2`, and one seccomp filter inside a
Codex-launched process.

The official OpenAI documentation describes the Linux dependency on bubblewrap,
unprivileged user namespaces, and the platform sandbox behavior:
<https://learn.chatgpt.com/es-419/docs/sandboxing>.

## The base-image regression

The Dockerfile previously used the moving tag:

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:debian
```

Two builds using that same text resolved to different images:

| Observed state | Working build | Failing build |
| --- | --- | --- |
| Dev Containers release label | `v0.4.29` | `v0.4.32` |
| Image metadata version | `2.1.11` | `2.1.15` |
| Image timestamp | 2026-07-01 | 2026-08-27 |
| Bubblewrap observed | `0.11.0` | `0.12.0` |
| Codex sandbox | Working | Failed mounting `/proc` |

On the failing image, every Codex-sandboxed command stopped before the requested
program ran:

```text
bwrap: Can't mount proc on /proc: Operation not permitted
```

The result was independent of the working directory. It failed in the repository,
in `.devcontainer`, and in `/tmp`; it was not specific to dot-directories. Direct
`unshare` and a minimal manual `bwrap` invocation worked in the outer container,
which showed that user namespaces and bubblewrap were generally available. The
failure was in the combination used by the Codex-generated sandbox.

Restoring `2.1.11-trixie` made the same Compose hardening settings work again. This
strongly associates the regression with the base-image refresh, but it does not
identify the exact changed package or upstream commit. In particular, the version
correlation alone does not prove that bubblewrap itself was the defect.

`cap_drop: ALL` was not the culprit: it remains enabled in the working setup.

## Verification procedure

Run these checks through a Codex shell command after every base-image, bubblewrap,
Codex CLI, Docker Desktop, or security-setting update. Running them directly in an
ordinary integrated terminal tests the container, not the inner Codex sandbox.

### 1. Confirm workspace writes, including a dot-directory

```sh
set -eu
probe_dir=source/codex-sandbox-check
hidden_dir=.codex-sandbox-check
trap 'rm -rf "$probe_dir" "$hidden_dir"; rmdir source 2>/dev/null || true' EXIT

mkdir -p "$probe_dir" "$hidden_dir"
printf 'workspace-ok\n' > "$probe_dir/original.txt"
mv "$probe_dir/original.txt" "$probe_dir/renamed.txt"
printf 'dotdir-ok\n' > "$hidden_dir/hidden.txt"
test "$(cat "$probe_dir/renamed.txt")" = workspace-ok
test "$(cat "$hidden_dir/hidden.txt")" = dotdir-ok
```

### 2. Confirm the boundary remains enforced

The following writes must fail with a read-only filesystem error:

```sh
touch /etc/codex-sandbox-must-not-write
touch .git/codex-sandbox-must-not-write
```

Neither target file should exist afterward:

```sh
test ! -e /etc/codex-sandbox-must-not-write
test ! -e .git/codex-sandbox-must-not-write
```

### 3. Inspect the inner process restrictions

```sh
awk '/^NoNewPrivs:|^Seccomp:|^Seccomp_filters:/ {print}' /proc/self/status
```

The known-good result has `NoNewPrivs` set to `1`, `Seccomp` set to `2` (filter
mode), and at least one seccomp filter.

## Upgrade procedure

1. Change only the base-image tag or digest.
2. Rebuild the Dev Container without using the old build cache.
3. Run all three verification checks above from a new Codex session.
4. Compare `docker inspect` security settings with the known-good values.
5. Keep the new image only if workspace writes succeed and protected writes fail.
6. Record the new immutable tag or digest here before merging the upgrade.

When diagnosing a regression, change one layer at a time. The Dev Container
Features currently use moving major-version tags as well, so pinning the base image
does not make the entire environment bit-for-bit reproducible.
