#!/usr/bin/env bash
# PostToolUse hook: runs after Claude Code Edit/Write/MultiEdit.
# Keep this fast. Lint only. Heavier checks (build, typecheck, phpcs, phpstan)
# stay as manual npm/composer scripts.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../bin/_pm-detect.sh
. "$ROOT_DIR/bin/_pm-detect.sh"

if [ ! -d node_modules ] || [ ! -x "node_modules/.bin/wp-scripts" ]; then
  echo "ai-after-edit: node_modules missing — skipping lint. Run 'npm install' to enable."
  exit 0
fi

if [ -f package.json ] && node -e "process.exit(require('./package.json').scripts?.lint ? 0 : 1)" 2>/dev/null; then
  $PM run lint
fi
