# uv cooldown check

This is a deliberately minimal Python project with one well-established PyPI
dependency: `pytest`.

From this directory, resolve and install it with:

```sh
uv lock
uv sync
```

Use the same commands after configuring uv's package release-age/cooldown
setting. `uv lock` is the useful command for checking whether that setting
affects dependency resolution.

Confirm the installed package with:

```sh
uv run pytest --version
```
