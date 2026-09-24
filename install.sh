#!/usr/bin/env bash
# ==============================================================================
# wnvim installer
# ==============================================================================
# Safe by design:
#   * NEVER deletes an existing user config — moves it to a timestamped backup
#     under ~/.local/share/wnvim/backups/nvim.<timestamp>/ (or your --prefix).
#   * Every path is derived from $HOME / XDG vars at runtime (portable).
#   * `rm -rf` is only ever called on paths this script created itself,
#     guarded by explicit existence + pattern checks.
#
# Usage:
#   ./install.sh [--standard | --custom <dir>] [--bin-dir <dir>]
#                [--no-plugins] [--help]
#
#   --standard        install into ~/.config/nvim (backs up any existing one)
#   --custom <dir>    keep your ~/.config/nvim; install wnvim into <dir> and
#                     run it ONLY through the `wnvim` launcher (default when a
#                     config already exists and you choose so interactively)
#   --bin-dir <dir>   where to place the `wnvim` launcher (default: ~/.local/bin)
#   --no-plugins      skip the headless plugin bootstrap step
# ==============================================================================

set -u

VERSION="0.1.0"
REPO_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd)"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
WNVIM_HOME="${XDG_DATA_HOME}/wnvim"          # our private state/backup root
BACKUP_ROOT="${WNVIM_HOME}/backups"

MODE=""            # standard | custom
CUSTOM_DIR=""
BIN_DIR="${HOME}/.local/bin"                 # launcher install dir (override: --bin-dir)
NO_PLUGINS=0
USE_APPNAME=0      # --appname: NVIM_APPNAME-based isolation instead of shim dirs

# ── pretty output helpers ─────────────────────────────────────────────────────
if [ -t 1 ]; then
  C_G='\033[32m'; C_Y='\033[33m'; C_R='\033[31m'; C_B='\033[1m'; C_0='\033[0m'
else
  C_G=''; C_Y=''; C_R=''; C_B=''; C_0=''
fi
ok()   { printf "${C_G}[ ok ]${C_0} %s\n" "$*"; }
warn() { printf "${C_Y}[warn]${C_0} %s\n" "$*"; }
err()  { printf "${C_R}[fail]${C_0} %s\n" "$*" >&2; }
step() { printf "\n${C_B}==> %s${C_0}\n" "$*"; }

usage() {
  sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --standard) MODE="standard"; shift ;;
    --custom)
      # Optional value: only consumed if it is not another --flag.
      if [ -n "${2:-}" ] && [ "${2#--}" = "$2" ]; then CUSTOM_DIR="$2"; shift 2; else MODE="custom"; shift; fi ;;
    --bin-dir)  BIN_DIR="${2:-}"; [ -z "$BIN_DIR" ] && { err "--bin-dir needs a path"; exit 2; }; shift 2 ;;
    --no-plugins) NO_PLUGINS=1; shift ;;
    --appname)  USE_APPNAME=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) err "Unknown option: $1 (see --help)"; exit 2 ;;
  esac
done

# ── 1. dependency checks ──────────────────────────────────────────────────────
step "1/8  Checking dependencies"

MISSING=0
for tool in git tar; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool found ($(command -v "$tool"))"
  else
    err "$tool is required but not installed."
    MISSING=1
  fi
done
if [ "$MISSING" != "0" ]; then
  err "Install the missing tools above and re-run. Nothing has been changed yet."
  exit 1
fi

# ── 2. detect Neovim ──────────────────────────────────────────────────────────
step "2/8  Detecting Neovim"

if ! command -v nvim >/dev/null 2>&1; then
  err "Neovim ('nvim') was not found on PATH."
  cat >&2 <<'EOF'

  Install Neovim >= 0.9 first, e.g.:
    Debian/Ubuntu : sudo apt install neovim   (older releases: use the appimage)
    Fedora        : sudo dnf install neovim
    Arch          : sudo pacman -S neovim
    openSUSE      : sudo zypper install neovim
    macOS         : brew install neovim
    Anywhere      : https://github.com/neovim/neovim/wiki/Installing-Neovim

EOF
  exit 1
fi

NVIM_VER="$(nvim --version | head -n1 | sed -E 's/^NVIM v?([0-9.]+).*$/\1/')"
NVIM_MAJOR="$(printf '%s' "$NVIM_VER" | cut -d. -f1)"
NVIM_MINOR="$(printf '%s' "$NVIM_VER" | cut -d. -f2)"
ok "Neovim ${NVIM_VER} found at $(command -v nvim)"

version_ok() {
  # $1 major $2 minor  -> true if >= 0.9
  [ "${1:-0}" -gt 0 ] && return 0
  [ "${2:-0}" -ge 9 ] && return 0
  return 1
}
if ! version_ok "$NVIM_MAJOR" "$NVIM_MINOR"; then
  err "wnvim needs Neovim >= 0.9 (found ${NVIM_VER}). Please upgrade."
  exit 1
fi

for opt in rg fd fzf node npm; do
  if command -v "$opt" >/dev/null 2>&1; then
    ok "optional: $opt"
  else
    warn "optional: $opt not found (some features degrade gracefully)"
  fi
done

# ── 3. decide install mode & detect existing config ───────────────────────────
step "3/8  Existing configuration check"

NVIM_CFG="${XDG_CONFIG_HOME}/nvim"
EXISTS_EXISTING=0
if [ -e "$NVIM_CFG" ] || [ -L "$NVIM_CFG" ]; then
  EXISTS_EXISTING=1
  ok "Found an existing Neovim config at: $NVIM_CFG"
else
  ok "No existing config at $NVIM_CFG — clean install."
fi

if [ -z "$MODE" ]; then
  if [ "$EXISTS_EXISTING" = "1" ]; then
    echo ""
    echo "You already have a Neovim configuration. Choose how to proceed:"
    echo "  1) custom  - keep your ~/.config/nvim untouched; wnvim lives in"
    echo "               ${WNVIM_HOME}/config and runs via the 'wnvim' command"
    echo "  2) standard- REPLACE ~/.config/nvim with wnvim (a timestamped backup"
    echo "               is created first; plain 'nvim' becomes wnvim)"
    REPLY=""
    if [ -t 0 ]; then
      read -r -p "Select [1] (recommended): " REPLY || REPLY=""
    else
      REPLY="1"
    fi
    case "${REPLY:-1}" in
      1|custom)  MODE="custom"; CUSTOM_DIR="${WNVIM_HOME}/config" ;;
      2|standard) MODE="standard" ;;
      *) err "Invalid choice."; exit 2 ;;
    esac
  else
    MODE="standard"
  fi
fi

if [ "$MODE" = "custom" ]; then
  if [ "$USE_APPNAME" = "1" ]; then
    # NVIM_APPNAME isolation: wnvim config lives in <config>/wnvim and the
    # launcher sets NVIM_APPNAME=wnvim. No shim dirs needed; Neovim itself
    # resolves config AND data/state dirs from the app name.
    [ -z "$CUSTOM_DIR" ] && CUSTOM_DIR="${XDG_CONFIG_HOME}/wnvim"
    TARGET_DIR="$CUSTOM_DIR"
    ok "Mode: custom (appname) — wnvim lives in ${TARGET_DIR}; plain 'nvim' untouched."
  else
    [ -z "$CUSTOM_DIR" ] && CUSTOM_DIR="${WNVIM_HOME}/config"
    TARGET_DIR="$CUSTOM_DIR"
    ok "Mode: custom — wnvim will live in ${TARGET_DIR}; your normal nvim is untouched."
  fi
elif [ "$MODE" = "standard" ]; then
  TARGET_DIR="$NVIM_CFG"
  ok "Mode: standard — installing into ${TARGET_DIR}."
else
  err "Internal error: no install mode chosen."; exit 1
fi

# Safety: refuse nonsense targets.
case "$TARGET_DIR" in
  ""|"/"|"$HOME"|"/root"|"/home") err "Refusing to install into '$TARGET_DIR'."; exit 2 ;;
esac
case "$TARGET_DIR" in
  "$HOME"/*|"${XDG_CONFIG_HOME}"*) : ;;
  *) warn "Target $TARGET_DIR is outside \$HOME/XDG paths — continuing because you chose it explicitly." ;;
esac

# ── 4. backup existing configuration ─────────────────────────────────────────
step "4/8  Backing up any existing configuration"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=""
if [ "$MODE" = "standard" ] && [ "$EXISTS_EXISTING" = "1" ]; then
  mkdir -p "$BACKUP_ROOT"
  DEST="${BACKUP_ROOT}/nvim.${TIMESTAMP}"
  if mv "$NVIM_CFG" "$DEST"; then
    BACKUP_CREATED="$DEST"
    ok "Existing config moved to: $DEST"
    # Also remember which data dirs may belong to the old setup (we do NOT
    # touch them; just documented for the user's restore convenience).
    printf '%s\n' "$DEST" > "${BACKUP_ROOT}/latest"
  else
    err "Could not move $NVIM_CFG to $DEST. Aborting safely — nothing changed."
    exit 1
  fi
else
  ok "Nothing to back up for this mode."
fi

# ── 5. install wnvim configuration ───────────────────────────────────────────
step "5/8  Installing wnvim configuration"

mkdir -p "$TARGET_DIR" || { err "Cannot create $TARGET_DIR"; exit 1; }

copy_failed=0
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete \
    --exclude '.git/' --exclude 'tests/' --exclude '.github/' \
    --exclude 'install.sh' --exclude 'Makefile' \
    "${REPO_DIR}/" "${TARGET_DIR}/" || copy_failed=1
else
  # Portable fallback without rsync: tar pipe with excludes.
  ( cd "$REPO_DIR" && tar cf - \
      --exclude='./.git' --exclude='./tests' --exclude='./.github' \
      --exclude='./install.sh' --exclude='./Makefile' . ) \
    | ( cd "$TARGET_DIR" && tar xf - ) || copy_failed=1
fi

if [ "$copy_failed" != "0" ]; then
  err "Copying files failed. Restoring backup..."
  if [ -n "$BACKUP_CREATED" ] && [ -e "$BACKUP_CREATED" ]; then
    rm -rf "$TARGET_DIR"
    mv "$BACKUP_CREATED" "$NVIM_CFG" && ok "Previous config restored."
  fi
  exit 1
fi
ok "Configuration copied to ${TARGET_DIR}"

# Record an install manifest used by the uninstaller.
mkdir -p "$WNVIM_HOME"
{
  printf 'VERSION=%s\n' "$VERSION"
  printf 'MODE=%s\n' "$MODE"
  printf 'TARGET_DIR=%s\n' "$TARGET_DIR"
  printf 'BACKUP=%s\n' "${BACKUP_CREATED:-none}"
  printf 'USE_APPNAME=%s\n' "$USE_APPNAME"
  printf 'XDG_CONFIG_HOME=%s\n' "$XDG_CONFIG_HOME"
  printf 'INSTALLED_AT=%s\n' "$(date -Iseconds)"
} > "${WNVIM_HOME}/install.manifest"
ok "Manifest written: ${WNVIM_HOME}/install.manifest"

# ── 6. install the wnvim launcher ─────────────────────────────────────────────
step "6/8  Installing the 'wnvim' launcher"

mkdir -p "$BIN_DIR" || { err "Cannot create ${BIN_DIR}"; exit 1; }
LAUNCHER="${BIN_DIR}/wnvim"
sed -e "s|__WNVIM_INSTALL_DIR__|${TARGET_DIR}|" \
    -e "s|__WNVIM_MODE__|${MODE}|" \
    -e "s|__WNVIM_USE_APPNAME__|${USE_APPNAME}|" \
    "${REPO_DIR}/scripts/wnvim.sh" > "${LAUNCHER}.tmp" \
  || { err "Failed to render launcher"; exit 1; }
chmod +x "${LAUNCHER}.tmp"
mv "${LAUNCHER}.tmp" "${LAUNCHER}"
ok "Launcher installed at ${LAUNCHER}"

# Record the launcher path + hash so the uninstaller can verify ownership.
if command -v sha256sum >/dev/null 2>&1; then
  LH="$(sha256sum "$LAUNCHER" | cut -d' ' -f1)"
elif command -v shasum >/dev/null 2>&1; then
  LH="$(shasum -a 256 "$LAUNCHER" | cut -d' ' -f1)"
else
  LH=""
fi
{
  printf 'LAUNCHER=%s\n' "$LAUNCHER"
  [ -n "$LH" ] && printf 'LAUNCHER_SHA256=%s\n' "$LH"
} >> "${WNVIM_HOME}/install.manifest"

if ! printf '%s' ":$PATH:" | grep -q ":${BIN_DIR}:"; then
  warn "${BIN_DIR} is not on your PATH."
  SHELLRC="${HOME}/.$(basename "${SHELL:-/bin/bash}")rc"
  case "${SHELL:-}" in
    */zsh)  SHELLRC="${HOME}/.zshrc" ;;
    */fish) SHELLRC="${HOME}/.config/fish/config.fish" ;;
  esac
  if [ "${SHELLRC##*/}" = "config.fish" ]; then
    LINE='fish_add_path ~/.local/bin'
  else
    LINE='export PATH="$HOME/.local/bin:$PATH"'
  fi
  if ! grep -Fq "$LINE" "$SHELLRC" 2>/dev/null; then
    printf '\n# wnvim: local bin on PATH\n%s\n' "$LINE" >> "$SHELLRC" 2>/dev/null \
      && ok "Added ${LINE} to ${SHELLRC}" \
      || warn "Add it yourself:  export PATH=\"${BIN_DIR}:\$PATH\""
  fi
fi

# ── 7. verify installation ────────────────────────────────────────────────────
step "7/8  Verifying installation"

# Load ONLY our config (via --clean + rtp prepend) and exercise the theme
# engine end-to-end for all 20 variants. No plugins required for this check.
if nvim --headless --clean --cmd "set rtp^=${TARGET_DIR}" \
    -c 'lua local okk,e=pcall(function() local t=require("wnvim.themes"); local st=t.styles(); assert(st[1] and st[10], "styles missing"); for i=1,10 do for _,m in ipairs({"day","night"}) do local n=0; for _ in pairs(t.build_highlights(i,m)) do n=n+1 end; assert(n>150, "too few highlights for style "..i) end end end); print(okk and "VERIFY_OK" or ("VERIFY_FAIL: "..tostring(e)))' \
    -c 'qa!' 2>&1 | tee /tmp/wnvim_verify.$$ | grep -q VERIFY_OK; then
  ok "Lua modules load correctly (theme engine verified for all 20 variants)."
else
  err "Verification failed. Output above; check that ${TARGET_DIR}/init.lua exists."
  if [ -n "$BACKUP_CREATED" ]; then
    echo "      Your previous config is safe at: $BACKUP_CREATED"
  fi
  exit 1
fi
rm -f /tmp/wnvim_verify.$$ 2>/dev/null || true

# Plugin bootstrap (needs network; failure is non-fatal).
if [ "$NO_PLUGINS" = "0" ]; then
  step "7b Bootstrapping plugins (this can take a few minutes)"
  BOOT_LOG="${WNVIM_HOME}/bootstrap.log"
  if [ "$MODE" = "custom" ] && [ "$USE_APPNAME" != "1" ]; then
    # Shim XDG_CONFIG_HOME containing ONLY our config as 'nvim' so Neovim
    # loads it without disturbing the user's real ~/.config/nvim.
    SHIM="$(mktemp -d "${TMPDIR:-/tmp}/wnvim-shim.XXXXXX")"
    mkdir -p "${SHIM}/nvim"
    ln -s "$TARGET_DIR" "${SHIM}/nvim" 2>/dev/null || cp -r "$TARGET_DIR" "${SHIM}/nvim"
    XDG_CONFIG_HOME="$SHIM" nvim --headless "+Lazy! sync" "+qa!" >"$BOOT_LOG" 2>&1
    RC=$?
    rm -rf "$SHIM"
  elif [ "$MODE" = "custom" ] && [ "$USE_APPNAME" = "1" ]; then
    NVIM_APPNAME="wnvim" nvim --headless "+Lazy! sync" "+qa!" >"$BOOT_LOG" 2>&1
    RC=$?
  else
    nvim --headless "+Lazy! sync" "+qa!" >"$BOOT_LOG" 2>&1
    RC=$?
  fi
  if [ $RC -eq 0 ]; then
    ok "Plugins installed (log: ${BOOT_LOG})"
  else
    warn "Plugin bootstrap reported errors — likely offline. Run 'wnvim' once;"
    warn "lazy.nvim will retry automatically, or run :Lazy Sync inside."
  fi
else
  ok "Skipped plugin bootstrap (--no-plugins). They install on first launch."
fi

# ── 8. next steps ─────────────────────────────────────────────────────────────
step "8/8  Done — next steps"

cat <<EOF

  ${C_B}wnvim ${VERSION} installed successfully.${C_0}

    Config dir   : ${TARGET_DIR}
    Launcher     : ${LAUNCHER}
    State/data   : ${WNVIM_HOME}
$([ -n "$BACKUP_CREATED" ] && echo "    Backup       : ${BACKUP_CREATED}  (restore with: ${LAUNCHER} --uninstall or see docs/RESTORE.md)")

  Try it now:
      wnvim --version
      wnvim --doctor
      wnvim somefile.py

  Inside Neovim:
      <Space> t h      theme selector (10 styles x day/night)
      :WnvimTheme      same, as a command
      <Leader> <Tab>   which-key help popup (press <Space> then wait)

  Docs: docs/KEYMAPS.md · docs/THEMES.md · docs/TROUBLESHOOTING.md
  Uninstall anytime: wnvim --uninstall   (your backup is restored)

EOF
exit 0
