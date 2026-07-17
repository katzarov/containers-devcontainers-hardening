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
index-strategy = "first-index"
keyring-provider = "disabled"
link-mode = "copy"
no-build = true
no-sources = true
prerelease = "disallow"

[[index]]
url = "https://pypi.org/simple"
default = true
EOF

export PATH="${INSTALL_DIR}:${PATH}"

# Environment settings take precedence over untrusted project configuration.
UV_HARDENING_ENV=(
  "UV_LOCKED=1"
  "UV_MALWARE_CHECK=1"
  "UV_NO_BUILD=1"
  "UV_NO_SOURCES=1"
  "UV_PRERELEASE=disallow"
)

for setting in "${UV_HARDENING_ENV[@]}"; do
  export "${setting}"
done

PROFILE_SNIPPET="${HOME}/.profile"
touch "${PROFILE_SNIPPET}"

if ! grep -Fqx "# uv hardening defaults" "${PROFILE_SNIPPET}"; then
  printf "%s\n" "" "# uv hardening defaults" >> "${PROFILE_SNIPPET}"
fi

for setting in "${UV_HARDENING_ENV[@]}"; do
  export_line="export ${setting}"
  if ! grep -Fqx "${export_line}" "${PROFILE_SNIPPET}"; then
    printf "%s\n" "${export_line}" >> "${PROFILE_SNIPPET}"
  fi
done

if [[ "$(uv --version)" != "uv ${UV_VERSION} "* ]]; then
  printf "Expected uv %s, found: %s\n" "${UV_VERSION}" "$(uv --version)" >&2
  exit 1
fi

uv --version
