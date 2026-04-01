#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COMMON_ARGS=()
OPENCODE_ARGS=()
CLAUDE_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-env)
      OPENCODE_ARGS+=("$1")
      ;;
    --no-claude-json)
      CLAUDE_ARGS+=("$1")
      ;;
    --copy|--symlink|--dry-run|--force)
      COMMON_ARGS+=("$1")
      ;;
    -h|--help)
      cat <<'HELP'
Usage: ./scripts/install-all.sh [options]

Runs both install-opencode.sh and install-claude.sh with compatible flags.

Shared options:
  --copy
  --symlink
  --dry-run
  --force

Installer-specific options:
  --no-env          Passed only to install-opencode.sh
  --no-claude-json  Passed only to install-claude.sh
  -h, --help        Show this help
HELP
      exit 0
      ;;
    *)
      printf '[install-all] Unknown option: %s
' "$1" >&2
      exit 1
      ;;
  esac
  shift
done

"$SCRIPT_DIR/install-opencode.sh" "${COMMON_ARGS[@]}" "${OPENCODE_ARGS[@]}"
"$SCRIPT_DIR/install-claude.sh" "${COMMON_ARGS[@]}" "${CLAUDE_ARGS[@]}"
