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
exclude-newer = "60 days"
EOF

export PATH="${INSTALL_DIR}:${PATH}"

uv --version
# uv sync --frozen