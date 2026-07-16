# RenderCV sandbox

This is a deliberately minimal Python project for installing and running `rendercv[full]` with uv.

From this directory, resolve and install it with:

```sh
uv lock
uv sync
```

RenderCV requires Python 3.12+. This base keeps dependency resolution in `pyproject.toml` and `uv.lock` so the install is repeatable.

Confirm the installed package with:

```sh
uv run rendercv --version
```

Create a starter CV with:

```sh
uv run rendercv new "John Doe"
```

Render a CV with:

```sh
uv run rendercv render "John_Doe_CV.yaml"
```
