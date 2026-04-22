#!/usr/bin/env bash
#
# bin/build-blocks.sh — compile src/blocks/*/block.json → build/blocks/.
#
# Uses @wordpress/scripts' default config (not the project's
# webpack.config.js, which is specific to the theme's main.js/main.scss
# bundle) so block discovery under src/blocks/ works without contention.
#
# Exits cleanly if src/blocks/ has no blocks — the first `npm run build`
# on a fresh project shouldn't fail just because nothing's there yet.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BLOCK_COUNT="$(find src/blocks -maxdepth 2 -name block.json 2>/dev/null | wc -l | tr -d ' ')"
if [ "$BLOCK_COUNT" = "0" ]; then
	echo "No blocks in src/blocks/ — skipping block build."
	exit 0
fi

exec ./node_modules/.bin/wp-scripts build \
	--webpack-src-dir=src/blocks \
	--output-path=build/blocks \
	--config node_modules/@wordpress/scripts/config/webpack.config.js
