#!/usr/bin/env bash
#
# bin/verify-theme.sh — Block theme standards verifier.
#
# Enforces the nine-item Technical Contract in CLAUDE.md and runs the
# standard lint/static-analysis stack. Non-zero exit on any failure.
#
# Run locally:  npm run verify
# Run from CI:  bin/verify-theme.sh

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAIL=0
pass() { printf "  \033[32m✓\033[0m %s\n" "$1"; }
fail() { printf "  \033[31m✗\033[0m %s\n" "$1"; FAIL=1; }
section() { printf "\n\033[1m%s\033[0m\n" "$1"; }

# ---------------------------------------------------------------------------
# 1. Tokens first. No raw hex/rgb/px in pattern or template markup.
# ---------------------------------------------------------------------------
section "1. Tokens first (no raw hex/rgb/px in patterns/templates/parts)"

# Scan only the content lines — skip PHP docblocks and HTML-comment header lines.
hex_hits=$(
	{ grep -rEn '#[0-9a-fA-F]{3,8}\b' patterns templates parts 2>/dev/null || true; } \
		| grep -v -E '^[^:]+:[0-9]+:[[:space:]]*(\*|//|<!--|\*/|/\*\*|\*\*)' \
		| grep -v -E '@package|@since|@return|@param' \
		|| true
)
if [ -n "$hex_hits" ]; then
	fail "raw hex color found in markup:"
	printf "%s\n" "$hex_hits" | sed 's/^/    /'
else
	pass "no raw hex colors in patterns/templates/parts"
fi

rgb_hits=$(
	{ grep -rEn '\brgba?\([^)]*\)' patterns templates parts 2>/dev/null || true; } \
		| grep -v -E '^[^:]+:[0-9]+:[[:space:]]*(\*|//|<!--)' \
		|| true
)
if [ -n "$rgb_hits" ]; then
	fail "raw rgb()/rgba() found in markup:"
	printf "%s\n" "$rgb_hits" | sed 's/^/    /'
else
	pass "no raw rgb()/rgba() in patterns/templates/parts"
fi

px_hits=$(
	{ grep -rEn '\b[0-9]+px\b' patterns templates parts 2>/dev/null || true; } \
		| grep -v -E '^[^:]+:[0-9]+:[[:space:]]*(\*|//|<!--|/\*\*)' \
		| grep -v -E 'Viewport Width' \
		| grep -v -E '"width":"[0-9]+px"' \
		| grep -v -E 'width="[0-9]+"' \
		|| true
)
# `px` in spacer/height attributes is tolerated for legacy core blocks;
# if you want to tighten further, remove the grep -v filters above.
if [ -n "$px_hits" ]; then
	# Treat as a warning surface — still report, but don't fail if every hit
	# is a known-ok pattern (outline/spacer heights, etc).
	offending=$(printf "%s\n" "$px_hits" | grep -vE ':[[:space:]]*<div style="height:\s*[0-9]+px"' || true)
	if [ -n "$offending" ]; then
		fail "raw px values in markup (outside known-ok spacers):"
		printf "%s\n" "$offending" | sed 's/^/    /'
	else
		pass "px values only appear in spacer heights (tolerated)"
	fi
else
	pass "no raw px values in patterns/templates/parts"
fi

# ---------------------------------------------------------------------------
# 3. Patterns compose; templates wire.
#    front-page.html must not contain content blocks other than header/main/pattern/footer.
# ---------------------------------------------------------------------------
section "3. Templates wire (front-page.html stays thin)"

if [ -f templates/front-page.html ]; then
	# Count block directives that aren't template-part / group (main) / pattern.
	bad=$(grep -E 'wp:(paragraph|heading|buttons?|image|cover|columns?|query|post-)' templates/front-page.html || true)
	if [ -n "$bad" ]; then
		fail "templates/front-page.html contains content blocks — move to a pattern"
		printf "%s\n" "$bad" | sed 's/^/    /'
	else
		pass "templates/front-page.html is pure wiring"
	fi
else
	fail "templates/front-page.html is missing"
fi

# ---------------------------------------------------------------------------
# 4. Section patterns use the _section-* prefix convention.
# ---------------------------------------------------------------------------
section "4. Section patterns follow _section-* convention"

missing_sections=0
for slug in hero cards writing cta; do
	if [ ! -f "patterns/_section-${slug}.php" ]; then
		fail "patterns/_section-${slug}.php is missing"
		missing_sections=1
	fi
done
[ $missing_sections -eq 0 ] && pass "all four baseline section patterns present"

# ---------------------------------------------------------------------------
# 5. Role, not format. No hardcoded /wp-content/themes/ paths in markup.
# ---------------------------------------------------------------------------
section "5. Role, not format (no hardcoded theme paths)"

hardcoded=$(grep -rEn '/wp-content/themes/' patterns templates parts 2>/dev/null || true)
if [ -n "$hardcoded" ]; then
	fail "hardcoded /wp-content/themes/ paths found — use get_theme_file_uri()"
	printf "%s\n" "$hardcoded" | sed 's/^/    /'
else
	pass "no hardcoded theme paths in markup"
fi

# ---------------------------------------------------------------------------
# 7. Fluid typography is on; no raw clamp() in patterns/templates.
# ---------------------------------------------------------------------------
section "7. Fluid typography"

if grep -qE '"fluid"[[:space:]]*:[[:space:]]*true' theme.json; then
	pass "theme.json declares settings.typography.fluid: true"
else
	fail "theme.json is missing settings.typography.fluid: true"
fi

clamp_hits=$(grep -rEn '\bclamp\(' patterns templates parts 2>/dev/null || true)
if [ -n "$clamp_hits" ]; then
	fail "raw clamp() in markup — move to a fontSize preset with fluid: { min, max }"
	printf "%s\n" "$clamp_hits" | sed 's/^/    /'
else
	pass "no raw clamp() in patterns/templates/parts"
fi

# Every rem-denominated fontSize preset larger than 1rem must carry a
# { min, max } fluid object. Body-scale presets (≤1rem) are exempt — fluid
# body text is a pessimization. Non-rem sizes are skipped (separate rule).
if command -v node > /dev/null; then
	if preset_output=$(node -e '
		const theme = require("./theme.json");
		const sizes = ((theme.settings || {}).typography || {}).fontSizes || [];
		const out = [];
		for (const p of sizes) {
			const m = /^([\d.]+)rem$/.exec(p.size || "");
			if (!m) continue;
			if (parseFloat(m[1]) > 1 && (!p.fluid || typeof p.fluid !== "object")) {
				out.push(p.slug + ": size " + p.size + " but no fluid { min, max } object");
			}
		}
		if (out.length) { console.log(out.join("\n")); process.exit(1); }
	' 2>&1); then
		pass "every heading-sized fontSize preset has a fluid object"
	else
		fail "fontSize presets missing fluid object (required when size > 1rem):"
		printf "%s\n" "$preset_output" | sed 's/^/    /'
	fi
else
	fail "node not found on PATH (cannot check fontSize presets)"
fi

# Every assets/fonts/ reference in theme.json fontFamilies[].fontFace[].src
# points at a real file. Only fires when the theme declares custom faces —
# system stacks (sans-serif / serif / monospace) are a no-op.
if command -v node > /dev/null; then
	if font_output=$(node -e '
		const theme = require("./theme.json");
		const fs = require("fs");
		const fams = ((theme.settings || {}).typography || {}).fontFamilies || [];
		const missing = [];
		for (const f of fams) {
			const faces = f.fontFace || [];
			for (const face of (Array.isArray(faces) ? faces : [faces])) {
				const srcs = face.src || [];
				for (const src of (Array.isArray(srcs) ? srcs : [srcs])) {
					if (typeof src !== "string") continue;
					const m = src.match(/(?:file:)?(\.?\/?assets\/fonts\/[^"\s)]+)/);
					if (!m) continue;
					const rel = m[1].replace(/^\.\//, "");
					if (!fs.existsSync(rel)) missing.push(rel + " (family: " + (f.slug || "?") + ")");
				}
			}
		}
		if (missing.length) { console.log(missing.join("\n")); process.exit(1); }
	' 2>&1); then
		pass "theme.json assets/fonts/ references resolve (or none declared)"
	else
		fail "theme.json references missing font files:"
		printf "%s\n" "$font_output" | sed 's/^/    /'
	fi
else
	fail "node not found on PATH (cannot check font references)"
fi

# ---------------------------------------------------------------------------
# 9. Every customTemplates entry has a file on disk.
# ---------------------------------------------------------------------------
section "9. Custom templates exist on disk"

# Extract the "name" values from the customTemplates array. This is a
# simple parser — good enough for theme.json, but only handles flat
# "name": "foo" pairs inside customTemplates.
names=$(awk '
	/"customTemplates"[[:space:]]*:/ { in_ct=1; depth=0; next }
	in_ct {
		n=gsub(/\[/, "["); depth+=n
		n=gsub(/\]/, "]"); depth-=n
		if (depth<=0 && match($0, /\]/)) { in_ct=0; next }
		if (match($0, /"name"[[:space:]]*:[[:space:]]*"[^"]+"/)) {
			s=substr($0, RSTART, RLENGTH)
			gsub(/.*"name"[[:space:]]*:[[:space:]]*"/, "", s)
			gsub(/".*/, "", s)
			print s
		}
	}
' theme.json)

missing=0
for name in $names; do
	if [ ! -f "templates/${name}.html" ]; then
		fail "theme.json customTemplate '$name' has no templates/${name}.html"
		missing=1
	fi
done
if [ -z "$names" ]; then
	pass "no customTemplates declared"
elif [ $missing -eq 0 ]; then
	pass "every customTemplates entry has a matching file"
fi

# ---------------------------------------------------------------------------
# Comment grammar (docs/conventions.md).
#   TODO(kind): is the only TODO form. Kinds: copy, design, content, a11y, perf.
#   FIXME / XXX / HACK are forbidden — rewrite as TODO(kind):.
# ---------------------------------------------------------------------------
section "Comment grammar (TODO(kind): only)"

bad_todos=$(
	{ grep -rEn '\bTODO\b' patterns templates parts assets 2>/dev/null || true; } \
		| grep -vE 'TODO\((copy|design|content|a11y|perf)\):' \
		|| true
)
if [ -n "$bad_todos" ]; then
	fail "TODO without a valid kind — allowed kinds: copy, design, content, a11y, perf"
	printf "%s\n" "$bad_todos" | sed 's/^/    /'
else
	pass "every TODO has a valid kind"
fi

forbidden=$(grep -rEn '\b(FIXME|XXX|HACK)\b' patterns templates parts assets 2>/dev/null || true)
if [ -n "$forbidden" ]; then
	fail "FIXME/XXX/HACK are forbidden — rewrite as TODO(kind):"
	printf "%s\n" "$forbidden" | sed 's/^/    /'
else
	pass "no FIXME/XXX/HACK"
fi

# ---------------------------------------------------------------------------
# Standard tool stack (build, lint, phpcs, phpstan).
# ---------------------------------------------------------------------------
section "Build / lint / phpcs / phpstan"

run() {
	local label="$1"; shift
	if "$@" > /tmp/wp-starter-verify-$$.log 2>&1; then
		pass "$label"
	else
		fail "$label"
		sed 's/^/    /' /tmp/wp-starter-verify-$$.log
	fi
	rm -f /tmp/wp-starter-verify-$$.log
}

if command -v npm > /dev/null; then
	run "npm run build"     npm run --silent build
	run "npm run lint"      npm run --silent lint
	run "npm run lint:css"  npm run --silent lint:css
else
	fail "npm not found on PATH"
fi

if command -v composer > /dev/null; then
	run "composer phpcs"    composer phpcs
	run "composer phpstan"  composer phpstan
else
	fail "composer not found on PATH"
fi

# ---------------------------------------------------------------------------
# Accessibility gate. The default `npm run a11y` script fails until the
# project wires up a real tool (pa11y, axe, lighthouse-ci, etc). This is
# the two-stage delivery model: preview passes, then a11y passes. Fresh
# repos intentionally fail here — the red is the signal to configure an
# a11y tool before shipping.
# ---------------------------------------------------------------------------
section "Accessibility"

if command -v npm > /dev/null; then
	run "npm run a11y"  npm run --silent a11y
else
	fail "npm not found on PATH (cannot run a11y)"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
printf "\n"
if [ $FAIL -ne 0 ]; then
	printf "\033[31mverify-theme: FAIL\033[0m\n"
	exit 1
fi
printf "\033[32mverify-theme: OK\033[0m\n"
