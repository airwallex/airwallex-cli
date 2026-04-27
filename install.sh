#!/bin/sh
# Airwallex CLI installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/airwallex/airwallex-cli/master/install.sh | sh
#
# Environment variables:
#   AIRWALLEX_VERSION       pin a specific release (default: latest, e.g. v0.1.0)
#   AIRWALLEX_INSTALL_DIR   install location (default: $HOME/.local/bin)

set -eu

REPO="airwallex/airwallex-cli"
BIN_NAME="airwallex"
INSTALL_DIR="${AIRWALLEX_INSTALL_DIR:-$HOME/.local/bin}"
STATE_DIR="${HOME}/.local/state/airwallex"
VERSION="${AIRWALLEX_VERSION:-latest}"

# Colors via terminfo so we get real ESC bytes (not literal '\033[…]').
# `tput setaf` is universally available on POSIX systems and respects
# $TERM. Falls back to empty strings when stdout isn't a tty (CI, log
# files) or terminfo doesn't know how to colour the current terminal.
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    BOLD=$(tput bold)
    DIM=$(tput dim)
    BLUE=$(tput setaf 4)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    RESET=$(tput sgr0)
else
    BOLD=''
    DIM=''
    BLUE=''
    GREEN=''
    YELLOW=''
    RED=''
    RESET=''
fi

# Output helpers. Glyphs are UTF-8; modern macOS / Linux terminals all
# render these correctly. Reserve plain ASCII fallbacks for the rare
# legacy terminal.
_lang="${LANG:-}${LC_ALL:-}"
case "$_lang" in
    *UTF-8*|*utf-8*|*utf8*)
        G_STEP='→'  G_OK='✓'  G_WARN='!'  G_ERR='✗' ;;
    *)
        G_STEP='*'  G_OK='+'  G_WARN='!'  G_ERR='x' ;;
esac

# Output levels:
#   header(): one-time banner at the top
#   step():   a unit of progress (blue arrow)
#   ok():     a success summary line (green check)
#   warn():   non-fatal warning (yellow bang)
#   err():    fatal error (red x), exits 1
header() { printf '\n%s%sairwallex CLI installer%s\n\n' "$BOLD" "$BLUE" "$RESET"; }
step()   { printf '  %s%s%s %s\n' "$BLUE"   "$G_STEP" "$RESET" "$*"; }
ok()     { printf '  %s%s%s %s\n' "$GREEN"  "$G_OK"   "$RESET" "$*"; }
warn()   { printf '  %s%s%s %s\n' "$YELLOW" "$G_WARN" "$RESET" "$*" >&2; }
err()    { printf '\n  %s%s%s %s\n\n' "$RED" "$G_ERR" "$RESET" "$*" >&2; exit 1; }

# Detect the platform and emit the asset-name fragment used in release
# filenames. macOS builds use `macos` and `x86_64`; Linux builds use
# `linux` and `amd64`.
detect_platform() {
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)

    case "$os" in
        darwin) os_label="macos" ;;
        linux)  os_label="linux" ;;
        *)      err "Unsupported OS: $os (supported: darwin, linux)" ;;
    esac

    case "$arch" in
        x86_64|amd64)
            case "$os_label" in
                macos) arch_label="x86_64" ;;
                *)     arch_label="amd64" ;;
            esac
            ;;
        arm64|aarch64)  arch_label="arm64" ;;
        *) err "Unsupported architecture: $arch (supported: x86_64, arm64)" ;;
    esac

    echo "${os_label}_${arch_label}"
}

# Return the absolute path to the shell rc file for PATH configuration.
# Falls back to ~/.profile when $SHELL is unset (common in minimal
# containers and piped-from-curl contexts).
resolve_rc_file() {
    case "${SHELL:-}" in
        */zsh)  echo "$HOME/.zshrc" ;;
        */bash) echo "$HOME/.bashrc" ;;
        */fish) echo "$HOME/.config/fish/config.fish" ;;
        *)      echo "$HOME/.profile" ;;
    esac
}

# Append a PATH export to a file unless it already contains INSTALL_DIR.
_patch_rc() {
    _file="$1"
    if [ -f "$_file" ] && grep -qF "$INSTALL_DIR" "$_file" 2>/dev/null; then
        return 0
    fi
    mkdir -p "$(dirname "$_file")"
    case "$_file" in
        */config.fish)
            printf '\nfish_add_path "%s"\n' "$INSTALL_DIR" >> "$_file" ;;
        *)
            printf '\nexport PATH="%s:$PATH"\n' "$INSTALL_DIR" >> "$_file" ;;
    esac
}

# Add INSTALL_DIR to PATH in the user's shell rc file. On Linux also
# patch ~/.profile so login shells (display-manager sessions, SSH, etc.)
# pick up the path without requiring an interactive-shell rc file.
ensure_path() {
    rc_file=$(resolve_rc_file)
    _patch_rc "$rc_file"

    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    if [ "$os" = "linux" ] && [ "$rc_file" != "$HOME/.profile" ]; then
        _patch_rc "$HOME/.profile"
    fi

    return 0
}

# Pre-flight: make sure we can actually write to INSTALL_DIR before downloading
# anything. Walk up the directory tree until we find an existing ancestor,
# since `mkdir -p` will create the intermediate directories.
check_writable() {
    dir="$1"
    target="$dir"
    while [ ! -d "$dir" ]; do
        dir=$(dirname "$dir")
    done
    if [ ! -w "$dir" ]; then
        err "$(printf '%s' "Cannot write to $target ($dir is not writable).
    Re-run with sudo, or pick a writable location:
        AIRWALLEX_INSTALL_DIR=\$HOME/.local/bin curl -fsSL ... | sh")"
    fi
}

# Resolve the latest release tag from the GitHub API. Asset filenames are
# versioned (airwallex_0.1.0_...), so we can't use the
# /releases/latest/download/<asset> redirect — we have to know the
# concrete version first.
resolve_latest_version() {
    api_url="https://api.github.com/repos/${REPO}/releases/latest"
    # `grep -E "tag_name"` then a portable cut to extract the value works
    # without jq, which is rarely pre-installed on minimal Linux images.
    tag=$(curl -fsSL "$api_url" 2>/dev/null \
        | grep -E '"tag_name"[[:space:]]*:' \
        | head -n 1 \
        | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
    if [ -z "$tag" ]; then
        err "Failed to resolve latest version from $api_url"
    fi
    echo "$tag"
}

main() {
    command -v curl >/dev/null 2>&1 || err "curl is required but not installed"
    command -v tar  >/dev/null 2>&1 || err "tar is required but not installed"

    header

    if [ "$VERSION" = "latest" ]; then
        VERSION=$(resolve_latest_version)
    fi
    step "Latest version: ${BOLD}${VERSION}${RESET}"

    # Strip a leading "v" so the asset filename matches the package version
    # embedded in pyproject.toml (e.g. v0.1.0 -> 0.1.0).
    version_no_v=${VERSION#v}

    platform=$(detect_platform)
    asset="airwallex_${version_no_v}_${platform}.tar.gz"
    url="https://github.com/${REPO}/releases/download/${VERSION}/${asset}"

    check_writable "$INSTALL_DIR"

    step "Downloading ${asset}"

    # Explicit template for portability across BSD/GNU mktemp variants.
    tmp=$(mktemp -d "${TMPDIR:-/tmp}/airwallex-cli.XXXXXX")
    trap 'rm -rf "$tmp"' EXIT

    if ! curl -fsSL -o "${tmp}/${asset}" "$url"; then
        err "Failed to download from $url"
    fi

    if ! tar -xzf "${tmp}/${asset}" -C "$tmp"; then
        err "Failed to extract ${asset}"
    fi

    if [ ! -f "${tmp}/${BIN_NAME}" ]; then
        err "Archive did not contain expected '${BIN_NAME}' binary"
    fi

    chmod +x "${tmp}/${BIN_NAME}"

    mkdir -p "$INSTALL_DIR"
    mv "${tmp}/${BIN_NAME}" "${INSTALL_DIR}/${BIN_NAME}"

    mkdir -p "$STATE_DIR"

    installed_version=$("${INSTALL_DIR}/${BIN_NAME}" --no-telemetry --version 2>/dev/null || echo "${version_no_v}")

    ok "Installed ${BOLD}${BIN_NAME} ${installed_version}${RESET} to ${DIM}${INSTALL_DIR}/${BIN_NAME}${RESET}"

    case ":$PATH:" in
        *":${INSTALL_DIR}:"*)
            ;;
        *)
            if ensure_path; then
                rc_file=$(resolve_rc_file)
                ok "Added ${BOLD}${INSTALL_DIR}${RESET} to ${BOLD}${rc_file}${RESET}"
                printf '\n  Restart your shell or run:\n        %ssource %s%s\n' \
                    "$DIM" "$rc_file" "$RESET"
            else
                printf '\n  %s%s%s %s%s%s is not on your PATH.\n' \
                    "$YELLOW" "$G_WARN" "$RESET" "$BOLD" "$INSTALL_DIR" "$RESET"
                printf '    Add it to your shell startup file:\n        %sexport PATH="%s:\$PATH"%s\n' \
                    "$DIM" "$INSTALL_DIR" "$RESET"
            fi
            ;;
    esac

    printf '\n  Run %s%s --help%s to get started.\n\n' "$BOLD" "$BIN_NAME" "$RESET"
}

main "$@"
