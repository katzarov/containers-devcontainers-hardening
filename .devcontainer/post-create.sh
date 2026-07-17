#!/usr/bin/env bash
set -euo pipefail

UV_VERSION="0.11.28"
INSTALL_DIR="${HOME}/.local/bin"
UV_CONFIG_DIR="${HOME}/.config/uv"

mkdir -p "${INSTALL_DIR}" "${UV_CONFIG_DIR}"

if [[ ! -x "${INSTALL_DIR}/uv" ]]; then
  curl -LsSf "https://astral.sh/uv/${UV_VERSION}/install.sh" \
    | env UV_UNMANAGED_INSTALL="${INSTALL_DIR}" sh
fi

cat > "${UV_CONFIG_DIR}/uv.toml" <<'EOF'
required-version = ">=0.11.28,<0.12"
exclude-newer = "60 days"
index-url = "https://pypi.org/simple"
index-strategy = "first-index"
keyring-provider = "disabled"
link-mode = "copy"
no-build = true
no-sources = true
prerelease = "disallow"
EOF

export PATH="${INSTALL_DIR}:${PATH}"
export UV_LOCKED=1

PROFILE_SNIPPET="${HOME}/.profile"
if ! grep -q "export UV_LOCKED=1" "${PROFILE_SNIPPET}" 2>/dev/null; then
  printf "%s\n" "" "# uv hardening defaults" "export UV_LOCKED=1" >> "${PROFILE_SNIPPET}"
fi

uv --version