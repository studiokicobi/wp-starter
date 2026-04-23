#!/usr/bin/env bash
# PostToolUse hook: runs after Claude Code Edit/Write/MultiEdit.
# Keep this fast. Lint only. Heavier checks (build, typecheck, phpcs, phpstan)
# stay as manual npm/composer scripts.
set -euo pipefail

if [ -f pnpm-lock.yaml ]; then
  PM="pnpm"
elif [ -f bun.lockb ] || [ -f bun.lock ]; then
  PM="bun"
else
  PM="npm"
fi

if [ ! -d node_modules ] || [ ! -x "node_modules/.bin/wp-scripts" ]; then
  echo "ai-after-edit: node_modules missing — skipping lint. Run 'npm install' to enable."
  exit 0
fi

if [ -f package.json ] && node -e "process.exit(require('./package.json').scripts?.lint ? 0 : 1)" 2>/dev/null; then
  $PM run lint
fi
