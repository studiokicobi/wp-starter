#!/usr/bin/env bash
#
# bin/test-rename.sh — non-regression smoke test for Issue #4.
#
# Runs `bin/rename-theme.sh` in an isolated git worktree against a slug that
# embeds the old slug as a substring, then asserts no double-suffix output
# appears. The worktree is torn down regardless of pass/fail, so this is safe
# to invoke from verify-theme.sh or locally against a dirty working tree.
#
# Usage: bash bin/test-rename.sh
#
# Wired into: bin/verify-theme.sh
# Issue:      https://github.com/studiokicobi/wp-starter/issues/4

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Precondition: only meaningful on a repo that still carries the old slug.
# Downstream forks have already renamed, so there's nothing to exercise.
if ! grep -q 'wp-starter' style.css 2>/dev/null; then
	echo "rename non-regression: skipped (repo is no longer in template state)"
	exit 0
fi

TEST_SLUG="wp-starter-collision-probe"
DOUBLED="${TEST_SLUG}-${TEST_SLUG#wp-starter-}"
DOUBLED_SNAKE="$(echo "$DOUBLED" | tr '-' '_')"

WORKTREE_DIR=""
LOG=""

cleanup() {
	local code=$?
	if [ -n "$WORKTREE_DIR" ] && [ -d "$WORKTREE_DIR" ]; then
		git worktree remove --force "$WORKTREE_DIR" > /dev/null 2>&1 || true
	fi
	[ -n "$LOG" ] && rm -f "$LOG" 2>/dev/null || true
	exit $code
}
trap cleanup EXIT

WORKTREE_DIR="$(mktemp -d -t wp-starter-rename-test.XXXXXX)"
LOG="$(mktemp -t wp-starter-rename-test-log.XXXXXX)"

# Detach so no branch is created; the worktree is a throwaway HEAD snapshot.
if ! git worktree add --quiet --detach "$WORKTREE_DIR" HEAD > /dev/null 2>&1; then
	echo "rename non-regression: FAIL (could not create worktree)"
	exit 1
fi

# Run the rename. Non-zero exit is acceptable — the safety check is expected
# to abort on a substring-collision slug. The key assertion is downstream:
# the working tree must not contain any double-suffix strings.
bash "$WORKTREE_DIR/bin/rename-theme.sh" "$TEST_SLUG" > "$LOG" 2>&1 || true

doubled=$(
	grep -rn \
		--exclude-dir=node_modules \
		--exclude-dir=vendor \
		--exclude-dir=.git \
		--exclude-dir=build \
		-- "$DOUBLED" "$WORKTREE_DIR" 2>/dev/null \
		| head -20 \
		|| true
)
doubled_snake=$(
	grep -rn \
		--exclude-dir=node_modules \
		--exclude-dir=vendor \
		--exclude-dir=.git \
		--exclude-dir=build \
		-- "$DOUBLED_SNAKE" "$WORKTREE_DIR" 2>/dev/null \
		| head -20 \
		|| true
)

if [ -n "$doubled" ] || [ -n "$doubled_snake" ]; then
	echo "rename non-regression: FAIL — double-suffix patterns found after rename:"
	[ -n "$doubled" ]       && printf '%s\n' "$doubled"       | sed 's/^/    /'
	[ -n "$doubled_snake" ] && printf '%s\n' "$doubled_snake" | sed 's/^/    /'
	echo
	echo "rename output (tail):"
	tail -20 "$LOG" | sed 's/^/    /'
	exit 1
fi

echo "rename non-regression: OK ($TEST_SLUG produced no double-suffix output)"
