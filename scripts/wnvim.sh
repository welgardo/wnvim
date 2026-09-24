#!/usr/bin/env bash
# ==============================================================================
# wnvim — launcher
# ==============================================================================
# Starts Neovim with the wnvim configuration, WITHOUT touching your normal
# `nvim` command or its default config resolution.
#
# Modes (recorded in this script by install.sh):
#   * standard : wnvim lives in ~/.config/nvim; plain `nvim` already IS wnvim.
#   * custom   : wnvim lives in a private directory. The launcher isolates it:
#       - appname mode (WNVIM_USE_APPNAME=1): config at <XDG_CONFIG>/wnvim,
#         launched via NVIM_APPNAME=wnvim (clean data/state separation too).
#       - shim mode  (default): a throwaway XDG_CONFIG_HOME containing only
#         the wnvim config is used, so your real ~/.config/nvim is untouched.
#
# Usage:
#   wnvim [any nvim arguments...]      open files / edit as usual
#   wnvim --help                       show help
#   wnvim --version                    print wnvim + nvim versions
#   wnvim --doctor                     environment health report
#   wnvim --update                     git pull + plugin sync
#   wnvim --uninstall                  remove wnvim (restores backups)
# ==============================================================================

set -u  # NOTE: intentionally NOT `set -e`: we forward exit codes ourselves.

# --- Record of where the wnvim config lives (written by install.sh) ----------
# Placeholders are replaced by the installer via sed during copy.
WNVIM_CONFIG_SOURCE="__WNVIM_INSTALL_DIR__"
WNVIM_MODE="__WNVIM_MODE__"            # "standard" | "custom"
WNVIM_USE_APPNAME="__WNVIM_USE_APPNAME__"  # "1" | "0"
WNVIM_VERSION="1.0.0"

SCRIPT_NAME="$(basename "$0")"

# True once install.sh has substituted the __WNVIM_*__ placeholders.
# Before substitution (i.e. running this script straight from the repo) the
# variables still contain the literal token, so we detect that case here.
is_installed() {
  case "$WNVIM_CONFIG_SOURCE$WNVIM_MODE" in
    *__WNVIM_*) return 1 ;;
    *)          return 0 ;;
  esac
}

repo_dir() {
  # Best-effort: if this script runs from a clone, the repo is one level up.
  local d
  d="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/.." && pwd)"
  [ -f "${d}/init.lua" ] && printf '%s' "$d"
}

print_help() {
  cat <<EOF
${SCRIPT_NAME} ${WNVIM_VERSION} — a polished Neovim distribution

Usage:
  ${SCRIPT_NAME} [nvim args...]        Launch Neovim with wnvim config
  ${SCRIPT_NAME} --help                Show this help
  ${SCRIPT_NAME} --version             Show wnvim and Neovim versions
  ${SCRIPT_NAME} --doctor              Run an environment health check
  ${SCRIPT_NAME} --update              Update wnvim (git pull + plugins)
  ${SCRIPT_NAME} --uninstall           Remove wnvim and restore backups

Inside Neovim:
  :WnvimTheme                          Pick style (1-10) + day/night
  :WnvimThemeDay / :WnvimThemeNight    Switch mode directly
  :WnvimUpdate / :WnvimDoctor          From within the editor too

Docs: README.md, docs/KEYMAPS.md, docs/THEMES.md
EOF
}

print_version() {
  printf 'wnvim %s\n' "${WNVIM_VERSION}"
  if command -v nvim >/dev/null 2>&1; then
    nvim --version | head -n 1 | sed 's/^/  /'
  else
    printf '  nvim: NOT FOUND on PATH\n'
  fi
}

have_nvim() {
  command -v nvim >/dev/null 2>&1
}

# Effective config dir for this invocation (handles repo-run mode too).
effective_config() {
  if is_installed; then
    printf '%s' "$WNVIM_CONFIG_SOURCE"
  else
    local d; d="$(repo_dir)"
    [ -n "$d" ] && printf '%s' "$d"
  fi
}

# Emit nvim CLI args that load ONLY the wnvim config, regardless of whether
# the user's own ~/.config/nvim exists (critical: shim isolation must never
# fall back to the user's config — Neovim would silently use $HOME otherwise).
run_with_wnvim_config() { # $1 = config dir, rest = extra nvim +commands
  local cfg="$1"; shift
  local vtmp="${TMPDIR:-/tmp}/wnvim-xdg.$$"
  mkdir -p "${vtmp}/nvim"
  ln -snf "$cfg" "${vtmp}/nvim" 2>/dev/null || cp -r "$cfg"/. "${vtmp}/nvim/"
  XDG_CONFIG_HOME="$vtmp" nvim --clean "--cmd" "set rtp^=${cfg}" \
    "+source ${cfg}/init.lua" "$@" 2>&1
  local rc=$?
  rm -rf "$vtmp"
  return $rc
}

nvim_for_config() { # $1 = config dir, rest = nvim args; launches isolated nvim
  local cfg="$1"; shift
  if [ "${WNVIM_USE_APPNAME}" = "1" ] || ! is_installed; then
    # appname mode: config lives at <XDG_CONFIG_HOME>/wnvim
    NVIM_APPNAME="wnvim" exec nvim "$@"
  else
    # Shim mode: a throwaway XDG_CONFIG_HOME containing ONLY our config as
    # 'nvim'. We symlink the whole directory (not its entries) so Neovim
    # resolves config/data/state under the shim and NEVER falls back to the
    # user's real $HOME paths.
    local shim
    shim="$(mktemp -d "${TMPDIR:-/tmp}/wnvim-cfg.XXXXXX")"
    mkdir -p "${shim}"
    ln -snf "$cfg" "${shim}/nvim" 2>/dev/null || cp -r "$cfg"/. "${shim}/nvim/"
    XDG_CONFIG_HOME="${shim}" nvim "$@"
    rc=$?
    rm -rf "${shim}"
    exit $rc
  fi
}

run_doctor() {
  if ! have_nvim; then
    echo "[wnvim] ERROR: 'nvim' not found on PATH." >&2
    echo "         Install Neovim >= 0.9: https://github.com/neovim/neovim/wiki/Installing-Neovim" >&2
    return 1
  fi
  local cfg; cfg="$(effective_config)"
  echo "[wnvim] Running diagnostics..."
  if [ "${WNVIM_MODE}" = "standard" ] && is_installed; then
    nvim --headless "+WnvimDoctor" "+qa!" 2>&1 | sed 's/^/  /'
    rc=${PIPESTATUS[0]}
  elif [ -n "$cfg" ] && [ -d "$cfg" ]; then
    run_with_wnvim_config "$cfg" "+WnvimDoctor" "+qa!" | sed 's/^/  /'
    rc=${PIPESTATUS[0]}
  else
    echo "[wnvim] Cannot locate wnvim config for doctor." >&2
    return 1
  fi
  if [ $rc -ne 0 ]; then
    echo "[wnvim] Quick fallback check:"
    nvim --headless "+lua print('nvim ok: '..tostring(vim.version()))" "+qa!" 2>&1 | sed 's/^/  /'
  fi
  return $rc
}

run_update() {
  local dir=""
  case "${WNVIM_MODE}" in
    custom)  dir="${WNVIM_CONFIG_SOURCE}" ;;
    standard) dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim" ;;
  esac
  if [ ! -d "${dir}/.git" ]; then
    echo "[wnvim] ${dir} is not a git checkout; cannot update automatically." >&2
    echo "         Re-run install.sh from a fresh clone instead." >&2
    return 1
  fi
  echo "[wnvim] Pulling updates in ${dir} ..."
  git -C "${dir}" pull --ff-only || { echo "[wnvim] git pull failed." >&2; return 1; }
  echo "[wnvim] Syncing plugins..."
  nvim --headless "+Lazy! sync" "+TSUpdate" "+qa!" 2>&1 | tail -n 3
  echo "[wnvim] Update complete."
}

launch() {
  if ! have_nvim; then
    echo "[wnvim] ERROR: Neovim ('nvim') is not installed or not on PATH." >&2
    echo "" >&2
    echo "  Install it, e.g.:" >&2
    echo "    Debian/Ubuntu: sudo apt install neovim   (or use the appimage from neovim releases)" >&2
    echo "    Fedora:        sudo dnf install neovim" >&2
    echo "    Arch:          sudo pacman -S neovim" >&2
    echo "    macOS:         brew install neovim" >&2
    exit 1
  fi

  local cfg; cfg="$(effective_config)"

  if [ "${WNVIM_MODE}" = "standard" ] && is_installed; then
    # wnvim IS ~/.config/nvim — plain nvim already loads it.
    exec nvim "$@"
  elif [ -n "$cfg" ] && [ -d "$cfg" ]; then
    # custom mode (appname or shim) and repo-run mode.
    nvim_for_config "$cfg" "$@"
  else
    echo "[wnvim] WARNING: wnvim config not found at '${WNVIM_CONFIG_SOURCE}'." >&2
    echo "[wnvim] Falling back to plain nvim with your default configuration." >&2
    exec nvim "$@"
  fi
}

main() {
  # Consume our own flags first; everything else forwards to nvim.
  while [ $# -gt 0 ]; do
    case "$1" in
      --help|-h)     print_help; exit 0 ;;
      --version|-V)  print_version; exit 0 ;;
      --doctor)      run_doctor; exit $? ;;
      --update)      run_update; exit $? ;;
      --uninstall)
        # Locate uninstall.sh: (a) next to the repo we were launched from,
        # (b) inside the installed config dir, (c) recorded in the manifest.
        local cand=""
        local cfg; cfg="$(effective_config)"
        local d; d="$(repo_dir)"
        if [ -n "$d" ] && [ -f "${d}/uninstall.sh" ]; then
          cand="${d}/uninstall.sh"
        elif [ -n "$cfg" ] && [ -f "${cfg}/uninstall.sh" ]; then
          cand="${cfg}/uninstall.sh"
        fi
        if [ -n "$cand" ]; then
          # Run via bash so the script works even without the +x bit.
          exec bash "$cand" "${@:2}"
        fi
        echo "[wnvim] uninstall.sh not found next to ${SCRIPT_NAME} or in the config dir." >&2
        echo "         Run it from the wnvim repository clone instead:" >&2
        echo "           ./uninstall.sh" >&2
        exit 1 ;;
      --) shift; break ;;
      *) break ;;  # unknown flag -> assume it's for nvim
    esac
    shift
  done
  launch "$@"
}

main "$@"
