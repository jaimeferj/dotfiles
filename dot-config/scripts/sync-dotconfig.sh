#!/usr/bin/env bash
# Syncs this repo with a remote machine over SSH (ignores .git dirs).
# Prefers syncing the whole dotfiles repo when the remote has ~/dotfiles; otherwise falls back to syncing dot-config only.
# Usage: sync-dotconfig.sh [--push|--pull] [--remote-path PATH] [--ssh "opts"] [--dry-run] user@host
#  --push (default): local -> remote target (default remote target: ~/.config unless ~/dotfiles exists)
#  --pull: remote target -> local
#  --remote-path: override remote target directory
#  --ssh: pass extra options to ssh (e.g., "-p 2222")
#  --dry-run: show changes without modifying files
# Examples:
#   sync-dotconfig.sh user@host
#   sync-dotconfig.sh --pull --dry-run user@host
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOCAL_DOTCONFIG="$REPO_ROOT/dot-config"
LOCAL_DOTFILES="$REPO_ROOT"

MODE="push"
REMOTE_PATH="~/.config"
SSH_OPTS=""
DRY_RUN=0
DRY_VERBOSE=0
REMOTE=""
REMOTE_BASE=""
LOCAL_BASE=""

usage() {
  cat <<'EOF'
Usage: sync-dotconfig.sh [--push|--pull] [--remote-path PATH] [--ssh "opts"] [--dry-run] user@host
Push (default): local -> remote target (default: ~/.config unless ~/dotfiles exists remotely)
Pull: remote target -> local
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --push)
    MODE="push"
    shift
    ;;
  --pull)
    MODE="pull"
    shift
    ;;
  --remote-path)
    [[ $# -ge 2 ]] || {
      usage
      exit 1
    }
    REMOTE_PATH="$2"
    shift 2
    ;;
  --ssh)
    [[ $# -ge 2 ]] || {
      usage
      exit 1
    }
    SSH_OPTS="$2"
    shift 2
    ;;
  --dry-run)
    DRY_RUN=1
    shift
    ;;
  --dry-run-verbose)
    DRY_RUN=1
    DRY_VERBOSE=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    REMOTE="$1"
    shift
    ;;
  esac
done

if [[ -z "$REMOTE" ]]; then
  usage
  exit 1
fi

if [[ ! -d "$LOCAL_DOTCONFIG" ]]; then
  echo "Local dot-config directory not found at $LOCAL_DOTCONFIG" >&2
  exit 1
fi

rsync_flags=(-az --delete --exclude='.git/' --exclude='.git' --exclude='tmux/plugins/')
# Ignore machine-generated or local-only paths.
rsync_flags+=(--exclude='dot-config/go/' --exclude='dot-config/uv/')
if [[ $DRY_RUN -eq 1 ]]; then
  rsync_flags+=(--dry-run --itemize-changes)
fi

if [[ -n "$SSH_OPTS" ]]; then
  rsync_flags+=(-e "ssh $SSH_OPTS")
fi

choose_remote_base() {
  local cmd=(ssh)
  [[ -n "$SSH_OPTS" ]] && cmd+=($SSH_OPTS)
  cmd+=("$REMOTE" "if [ -d ~/dotfiles ]; then cd ~/dotfiles && pwd; else printf '%s' \"$REMOTE_PATH\"; fi")
  REMOTE_BASE="$("${cmd[@]}")"
}

choose_remote_base

if [[ "$REMOTE_BASE" =~ /dotfiles/?$ ]]; then
  LOCAL_BASE="$LOCAL_DOTFILES"
else
  LOCAL_BASE="$LOCAL_DOTCONFIG"
fi

if [[ "$MODE" == "push" ]]; then
  SRC="$LOCAL_BASE/"
  DEST="$REMOTE:$REMOTE_BASE/"
else
  SRC="$REMOTE:$REMOTE_BASE/"
  DEST="$LOCAL_BASE/"
fi

echo "Sync mode: $MODE"
echo "Source: $SRC"
echo "Dest:   $DEST"
if [[ $DRY_RUN -eq 1 && $DRY_VERBOSE -eq 0 ]]; then
  # Suppress unchanged entries (those starting with ".") unless verbose dry-run requested.
  rsync "${rsync_flags[@]}" "$SRC" "$DEST" | grep -v '^[.]' || true
else
  rsync "${rsync_flags[@]}" "$SRC" "$DEST"
fi
