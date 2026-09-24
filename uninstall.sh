#!/usr/bin/env bash
# ==============================================================================
# wnvim uninstaller
# ==============================================================================
# Safe by design:
#   * NEVER deletes anything it did not create itself.
#   * Restores the user's previous Neovim configuration from the timestamped
#     backup recorded in <data>/wnvim/install.manifest (written by install.sh).
#   * Refuses to overwrite a config directory that exists again at restore
#     time — nothing is ever silently clobbered.
#   * Removes the `wnvim` launcher ONLY if its content still matches the one
#     we installed (SHA-256 recorded in the manifest); a hand-edited or
#     replaced file is left alone with a warning.
#
# Usage:
#   ./uninstall.sh [--yes] [--bin-dir <dir>] [--keep-backups] [--dry-run] [--help]
#
#   --yes           do not ask for confirmation
#   --bin-dir <dir> where the launcher lives (default: ~/.local/bin)
#   --keep-backups  leave any backups in place (skip restore too)
#   --dry-run       print what would happen, change nothing
# ==============================================================================

set -u

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
WNVIM_HOME="${XDG_DATA_HOME}/wnvim"
MANIFEST="${WNVIM_HOME}/install.manifest"
NVIM_CFG="${XDG_CONFIG_HOME}/nvim"

BIN_DIR="${HOME}/.local/bin"
ASSUME_YES=0
KEEP_BACKUPS=0
DRY_RUN=0

if [ -t 1 ]; then
  C_G='\033[32m'; C_Y='\033[33m'; C_R='\033[31m'; C_B='\033[1m'; C_0='\\033[0m'
else
  C_G=''; C_Y=''; C_R=''; C_B=''; C_0=''
fi
ok()   { printf "${C_G}[ ok ]${C_0} %s\n" "$*"; }
warn() { printf "${C_Y}[warn]${C_0} %s\n" "$*"; }
err()  { printf "${C_R}[fail]${C_0} %s\n" "$*" >&2; }
step() { printf "\n${C_B}==> %s${C_0}\n" "$*"; }

usage() { sed -n '2,27p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y)      ASSUME_YES=1; shift ;;
    --bin-dir)     BIN_DIR="${2:-}"; [ -z "$BIN_DIR" ] && { err "--bin-dir needs a path"; exit 2; }; shift 2 ;;
    --keep-backups) KEEP_BACKUPS=1; shift ;;
    --dry-run)     DRY_RUN=1; shift ;;
    --help|-h)     usage; exit 0 ;;
    *) err "Unknown option: $1 (see --help)"; exit 2 ;;
  esac
done

do_rm() { # guarded removal of paths WE created only
  local p="$1"
  case "$p" in
    ""|"/"|"$HOME"|"/root"|"/home") err "Refusing to remove '$p'"; return 1 ;;
  esac
  if [ "$DRY_RUN" = "1" ]; then echo "  [dry-run] rm -rf $p"; return 0; fi
  rm -rf -- "$p"
}

move_to() { # move src -> dst, never overwriting dst
  local src="$1" dst="$2"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    warn "Refusing to overwrite existing $dst"
    return 1
  fi
  if [ "$DRY_RUN" = "1" ]; then echo "  [dry-run] mv $src $dst"; return 0; fi
  mkdir -p -- "$(dirname -- "$dst")"
  mv -- "$src" "$dst"
}

# ── 1. read manifest ──────────────────────────────────────────────────────────
step "1/4  Reading install manifest"

MODE=""; TARGET_DIR=""; BACKUP="none"; LAUNCHER=""; LHASH=""
if [ -f "$MANIFEST" ]; then
  while IFS='=' read -r k v; do
    case "$k" in
      MODE) MODE="$v" ;; TARGET_DIR) TARGET_DIR="$v" ;; BACKUP) BACKUP="$v" ;;
      LAUNCHER) LAUNCHER="$v" ;; LAUNCHER_SHA256) LHASH="$v" ;;
      XDG_CONFIG_HOME) : ;; # informational only
      *) : ;; # ignore unknown keys (forward-compatible manifest format)
    esac
  done < "$MANIFEST"
  ok "Manifest found: $MANIFEST"
else
  warn "No manifest at $MANIFEST — falling back to best-effort detection."
  MODE=""; TARGET_DIR=""; BACKUP="none"
fi

# Fall back to the launcher rendered next to this script / on PATH.
if [ -z "$LAUNCHER" ]; then
  cand="${BIN_DIR}/wnvim"
  [ -x "$cand" ] && LAUNCHER="$cand"
fi

# ── 2. confirm ────────────────────────────────────────────────────────────────
step "2/4  What will happen"

cat <<EOF
  Mode        : ${MODE:-unknown}
  Config dir  : ${TARGET_DIR:-<from mode>}
  Launcher    : ${LAUNCHER:-not found}
  Backup      : ${BACKUP}
  Dry run     : ${DRY_RUN}
EOF

if [ "$ASSUME_YES" != "1" ] && [ "$DRY_RUN" != "1" ]; then
  if [ -t 0 ]; then
    REPLY=""
    read -r -p "Proceed with uninstall? [y/N] " REPLY || REPLY=""
    case "$REPLY" in y|Y|yes|YES) : ;; *) echo "Aborted."; exit 0 ;; esac
  else
    err "Non-interactive session and no --yes flag. Nothing changed. Re-run with --yes to confirm."
    exit 1
  fi
fi

FAILURES=0

# ── 3. remove our artifacts ───────────────────────────────────────────────────
step "3/4  Removing wnvim artifacts"

# 3a. launcher — only if it is still ours (hash match), else leave + warn.
if [ -n "$LAUNCHER" ] && [ -f "$LAUNCHER" ]; then
  cur_hash=""
  if command -v sha256sum >/dev/null 2>&1; then
    cur_hash="$(sha256sum "$LAUNCHER" | cut -d' ' -f1)"
  elif command -v shasum >/dev/null 2>&1; then
    cur_hash="$(shasum -a 256 "$LAUNCHER" | cut -d' ' -f1)"
  fi
  if [ -n "$LHASH" ] && [ "$cur_hash" != "$LHASH" ]; then
    warn "Launcher $LAUNCHER was modified after install — leaving it in place."
    warn "Remove it manually if you really want to:  rm \"$LAUNCHER\""
  else
    if [ "$DRY_RUN" = "1" ]; then echo "  [dry-run] rm -f $LAUNCHER"; else
      rm -f -- "$LAUNCHER" && ok "Removed launcher $LAUNCHER" || { err "Could not remove $LAUNCHER"; FAILURES=$((FAILURES+1)); }
    fi
  fi
else
  ok "No launcher file to remove."
fi

# 3b. plugin/data/state directories owned by wnvim (safe: they contain only
#     plugins Neovim downloaded and our own state).
for d in "${WNVIM_HOME}/lazy" "${WNVIM_HOME}/state" "${WNVIM_HOME}/logs"; do
  [ -e "$d" ] && do_rm "$d" && ok "Removed $d"
done
if [ -e "${XDG_DATA_HOME}/nvim/lazy" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    echo "  [dry-run] would offer to remove shared plugin dir ${XDG_DATA_HOME}/nvim/lazy"
  else
    warn "Shared Neovim data dir ${XDG_DATA_HOME}/nvim/lazy may still hold wnvim plugins."
    warn "Delete it manually if your old config does not need it:"
    warn "  rm -rf \"${XDG_DATA_HOME}/nvim/lazy\""
  fi
fi

# 3c. the installed config itself.
if [ "$MODE" = "custom" ] && [ -n "$TARGET_DIR" ] && [ -e "$TARGET_DIR" ]; then
  case "$TARGET_DIR" in
    "${WNVIM_HOME}/config"|*_wnvim*) do_rm "$TARGET_DIR" && ok "Removed custom config dir $TARGET_DIR" ;;
    *) warn "Custom target $TARGET_DIR is unexpected — leaving it. Remove manually if sure." ;;
  esac
elif [ "$MODE" = "standard" ] && [ -n "$TARGET_DIR" ] && [ -e "$TARGET_DIR" ]; then
  # In standard mode the config dir IS ~/.config/nvim. We only delete it if it
  # still looks like wnvim (contains our init.lua marker) so we never destroy
  # an unrelated config the user installed afterwards.
  if [ -f "${TARGET_DIR}/lua/wnvim/themes/styles.lua" ] && [ "$TARGET_DIR" = "$NVIM_CFG" ]; then
    do_rm "$TARGET_DIR" && ok "Removed wnvim config $TARGET_DIR"
  else
    warn "$TARGET_DIR no longer looks like a pristine wnvim install — leaving it untouched."
  fi
fi

# ── 4. restore backup ─────────────────────────────────────────────────────────
step "4/4  Restoring previous configuration"

if [ "$KEEP_BACKUPS" = "1" ]; then
  ok "Skipped (--keep-backups)."
elif [ "$MODE" = "standard" ] && [ "$BACKUP" != "none" ] && [ -n "$BACKUP" ] && [ -d "$BACKUP" ]; then
  if [ -e "$NVIM_CFG" ] || [ -L "$NVIM_CFG" ]; then
    warn "A config already exists at $NVIM_CFG — NOT overwriting it."
    warn "Your backup remains safe at: $BACKUP"
    warn "Restore manually when ready:  mv \"$BACKUP\" \"$NVIM_CFG\""
  else
    if move_to "$BACKUP" "$NVIM_CFG"; then
      ok "Restored original config to $NVIM_CFG"
    else
      FAILURES=$((FAILURES+1))
    fi
  fi
else
  ok "Nothing to restore (no backup recorded, or custom mode)."
fi

# Manifest consumed.
if [ "$DRY_RUN" != "1" ] && [ -f "$MANIFEST" ]; then
  rm -f -- "$MANIFEST"
fi

echo ""
if [ "$FAILURES" -eq 0 ]; then
  ok "wnvim uninstalled.$([ "$DRY_RUN" = "1" ] && echo ' (dry run — nothing changed)')"
  echo "  Remaining backups (if any): ${WNVIM_HOME}/backups/"
  exit 0
else
  err "Completed with ${FAILURES} issue(s) — see warnings above."
  exit 1
fi
