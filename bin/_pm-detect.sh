#!/usr/bin/env bash
# Shared package-manager detection for bin/verify-theme.sh and
# scripts/ai-after-edit.sh. Sets PM to pnpm / bun / npm based on the
# lockfile present in the current repo root.
#
# This file is sourced — it must not be executed directly and must not
# rely on shell-option inheritance (the callers set -e / -u themselves).

if [ -f pnpm-lock.yaml ]; then
	PM="pnpm"
elif [ -f bun.lockb ] || [ -f bun.lock ]; then
	PM="bun"
else
	PM="npm"
fi
