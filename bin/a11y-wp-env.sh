#!/usr/bin/env bash
#
# Run pa11y-ci against the active wp-env site at desktop and mobile widths.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v npx > /dev/null 2>&1; then
	echo "error: npx not found on PATH" >&2
	exit 1
fi

if ! command -v curl > /dev/null 2>&1; then
	echo "error: curl not found on PATH" >&2
	exit 1
fi

WP_URL=$(
	npx --silent wp-env run cli wp option get home --skip-themes --skip-plugins 2>/dev/null \
		| grep -oE '^https?://[^[:space:]]+$' \
		| head -1 \
		|| true
)

if [ -z "$WP_URL" ]; then
	echo "error: wp-env is not reachable; start it with 'npm run env:start'" >&2
	exit 1
fi

WP_URL="${WP_URL%/}"
if ! curl -fsS --max-time 5 "$WP_URL/" > /dev/null 2>&1; then
	echo "error: wp-env URL is not responding: $WP_URL" >&2
	exit 1
fi

pa11y_tmpdir=$(mktemp -d)
trap 'rm -rf "$pa11y_tmpdir"' EXIT

desktop_cfg="$pa11y_tmpdir/desktop.json"
mobile_cfg="$pa11y_tmpdir/mobile.json"

cat > "$desktop_cfg" <<'JSON'
{
	"defaults": {
		"standard": "WCAG2AA",
		"timeout": 30000,
		"includeWarnings": false,
		"chromeLaunchConfig": { "args": [ "--no-sandbox", "--disable-dev-shm-usage" ] },
		"viewport": { "width": 1280, "height": 800 }
	}
}
JSON

cat > "$mobile_cfg" <<'JSON'
{
	"defaults": {
		"standard": "WCAG2AA",
		"timeout": 30000,
		"includeWarnings": false,
		"chromeLaunchConfig": { "args": [ "--no-sandbox", "--disable-dev-shm-usage" ] },
		"viewport": { "width": 375, "height": 667 }
	}
}
JSON

npx --silent pa11y-ci --config "$desktop_cfg" "$WP_URL/" "$WP_URL/?p=1"
npx --silent pa11y-ci --config "$mobile_cfg" "$WP_URL/" "$WP_URL/?p=1"
