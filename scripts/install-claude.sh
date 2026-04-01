#!/usr/bin/env bash
set -euo pipefail

MODE='copy'
DRY_RUN='false'
FORCE='false'
NO_CLAUDE_JSON='false'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC_CLAUDE_MD="$REPO_DIR/CLAUDE.md"
SRC_SETTINGS="$REPO_DIR/claude/settings.json"
SRC_AGENTS_DIR="$REPO_DIR/claude/agents"
SRC_SKILLS_DIR="$REPO_DIR/claude/skills"
SRC_CLAUDE_JSON="$REPO_DIR/.claude.json"

DEST_ROOT="$HOME/.claude"
DEST_CLAUDE_MD="$DEST_ROOT/CLAUDE.md"
DEST_SETTINGS="$DEST_ROOT/settings.json"
DEST_AGENTS_DIR="$DEST_ROOT/agents"
DEST_SKILLS_DIR="$DEST_ROOT/skills"
DEST_CLAUDE_JSON="$HOME/.claude.json"

log() {
  printf '[install-claude] %s\n' "$*"
}

run_cmd() {
  if [[ "$DRY_RUN" == 'true' ]]; then
    printf '[install-claude] DRY RUN:'
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
    return 0
  fi

  "$@"
}

exists() {
  [[ -e "$1" || -L "$1" ]]
}

backup_path() {
  local path="$1"
  if exists "$path"; then
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    local backup="${path}.bak-${ts}"
    run_cmd cp -a "$path" "$backup"
    log "Backed up $path -> $backup"
  fi
}

usage() {
  cat <<'HELP'
Usage: ./scripts/install-claude.sh [options]

Installs Claude Code config from this repo into your user home.

Options:
  --copy             Copy files/directories (default)
  --symlink          Symlink CLAUDE.md, agents, and skills from this repo
  --dry-run          Print planned actions without changing files
  --force            Replace existing targets in symlink mode without preserving directory contents
  --no-claude-json   Skip install/merge of ~/.claude.json
  -h, --help         Show this help

Examples:
  ./scripts/install-claude.sh --dry-run
  ./scripts/install-claude.sh --copy
  ./scripts/install-claude.sh --symlink
HELP
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --copy)
      MODE='copy'
      ;;
    --symlink)
      MODE='symlink'
      ;;
    --dry-run)
      DRY_RUN='true'
      ;;
    --force)
      FORCE='true'
      ;;
    --no-claude-json)
      NO_CLAUDE_JSON='true'
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ ! -f "$SRC_CLAUDE_MD" || ! -f "$SRC_SETTINGS" || ! -d "$SRC_AGENTS_DIR" || ! -d "$SRC_SKILLS_DIR" ]]; then
  log 'Required source files are missing. Run this script from the repo checkout.'
  exit 1
fi

run_cmd mkdir -p "$DEST_ROOT"

if [[ "$MODE" == 'copy' ]]; then
  if exists "$DEST_CLAUDE_MD"; then
    backup_path "$DEST_CLAUDE_MD"
  fi
  run_cmd cp "$SRC_CLAUDE_MD" "$DEST_CLAUDE_MD"

  run_cmd mkdir -p "$DEST_AGENTS_DIR" "$DEST_SKILLS_DIR"
  run_cmd rsync -a "$SRC_AGENTS_DIR/" "$DEST_AGENTS_DIR/"
  run_cmd rsync -a "$SRC_SKILLS_DIR/" "$DEST_SKILLS_DIR/"

  log 'Installed CLAUDE.md, agents, and skills (copy mode).'
else
  if [[ "$FORCE" == 'true' ]]; then
    run_cmd rm -rf "$DEST_CLAUDE_MD" "$DEST_AGENTS_DIR" "$DEST_SKILLS_DIR"
  else
    if exists "$DEST_CLAUDE_MD" && [[ ! -L "$DEST_CLAUDE_MD" ]]; then
      backup_path "$DEST_CLAUDE_MD"
      run_cmd rm -f "$DEST_CLAUDE_MD"
    fi
    if exists "$DEST_AGENTS_DIR" && [[ ! -L "$DEST_AGENTS_DIR" ]]; then
      backup_path "$DEST_AGENTS_DIR"
      run_cmd rm -rf "$DEST_AGENTS_DIR"
    fi
    if exists "$DEST_SKILLS_DIR" && [[ ! -L "$DEST_SKILLS_DIR" ]]; then
      backup_path "$DEST_SKILLS_DIR"
      run_cmd rm -rf "$DEST_SKILLS_DIR"
    fi
  fi

  run_cmd ln -sfn "$SRC_CLAUDE_MD" "$DEST_CLAUDE_MD"
  run_cmd ln -sfn "$SRC_AGENTS_DIR" "$DEST_AGENTS_DIR"
  run_cmd ln -sfn "$SRC_SKILLS_DIR" "$DEST_SKILLS_DIR"

  log 'Installed CLAUDE.md, agents, and skills (symlink mode).'
fi

merge_settings_with_jq() {
  local user_file="$1"
  local repo_file="$2"
  local tmp
  tmp="$(mktemp)"

  jq -s '
    .[0] as $user |
    .[1] as $repo |
    ($repo * $user)
    | .permissions.allow = ((($repo.permissions.allow // []) + ($user.permissions.allow // [])) | unique)
    | .hooks.Notification = ((($repo.hooks.Notification // []) + ($user.hooks.Notification // [])) | unique)
  ' "$user_file" "$repo_file" > "$tmp"

  run_cmd cp "$tmp" "$user_file"
  rm -f "$tmp"
}

merge_claude_json_with_jq() {
  local user_file="$1"
  local repo_file="$2"
  local tmp
  tmp="$(mktemp)"

  jq -s '
    .[0] as $user |
    .[1] as $repo |
    ($repo * $user)
    | .mcpServers = (($repo.mcpServers // {}) + ($user.mcpServers // {}))
  ' "$user_file" "$repo_file" > "$tmp"

  run_cmd cp "$tmp" "$user_file"
  rm -f "$tmp"
}

if exists "$DEST_SETTINGS"; then
  backup_path "$DEST_SETTINGS"
  if command -v jq >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == 'true' ]]; then
      log "DRY RUN: merge $SRC_SETTINGS into $DEST_SETTINGS with jq"
    else
      merge_settings_with_jq "$DEST_SETTINGS" "$SRC_SETTINGS"
    fi
    log 'Merged settings into ~/.claude/settings.json using jq.'
  else
    log 'jq not found. Replacing ~/.claude/settings.json with template after backup.'
    run_cmd cp "$SRC_SETTINGS" "$DEST_SETTINGS"
  fi
else
  run_cmd cp "$SRC_SETTINGS" "$DEST_SETTINGS"
  log 'Installed ~/.claude/settings.json from template.'
fi

if [[ "$NO_CLAUDE_JSON" == 'true' ]]; then
  log 'Skipping ~/.claude.json install/merge (--no-claude-json).'
elif [[ ! -f "$SRC_CLAUDE_JSON" ]]; then
  log 'Repo .claude.json template not found; skipping ~/.claude.json install/merge.'
else
  if exists "$DEST_CLAUDE_JSON"; then
    backup_path "$DEST_CLAUDE_JSON"
    if command -v jq >/dev/null 2>&1; then
      if [[ "$DRY_RUN" == 'true' ]]; then
        log "DRY RUN: merge $SRC_CLAUDE_JSON into $DEST_CLAUDE_JSON with jq"
      else
        merge_claude_json_with_jq "$DEST_CLAUDE_JSON" "$SRC_CLAUDE_JSON"
      fi
      log 'Merged template into ~/.claude.json using jq.'
    else
      log 'jq not found. Replacing ~/.claude.json with template after backup.'
      run_cmd cp "$SRC_CLAUDE_JSON" "$DEST_CLAUDE_JSON"
    fi
  else
    run_cmd cp "$SRC_CLAUDE_JSON" "$DEST_CLAUDE_JSON"
    log 'Installed ~/.claude.json from template.'
  fi
fi

log 'Done.'
