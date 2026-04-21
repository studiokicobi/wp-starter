#!/usr/bin/env bash
#
# bin/rename-theme.sh — single-pass theme slug rename.
#
# Renames every reference to `wp-starter` (and its snake_case sibling
# `wp_starter_`) to a project-specific slug, across:
#
#   - PHP text domains:                     'wp-starter' → '<slug>'
#   - PHP function prefixes:                 wp_starter_ → <slug_snake>_
#   - @package docblock tags:               @package wp-starter → @package <slug>
#   - Pattern slugs in PHP headers:         Slug: wp-starter/... → Slug: <slug>/...
#   - Pattern slugs in template markup:     wp:pattern {"slug":"wp-starter/..."} → <slug>
#   - Enqueue handles in functions.php:     'wp-starter-style' etc. → '<slug>-…'
#   - style.css header:                     Text Domain, Theme URI
#   - composer.json:                        "name": "vendor/wp-starter" → "vendor/<slug>"
#   - package.json:                         "name": "wp-starter" → "<slug>"
#   - phpcs.xml.dist:                       text_domain + prefixes elements
#
# Project-specific fields that vary per project are NOT auto-edited
# (Theme Name, Description, Author, Tags, composer vendor). Review
# style.css and composer.json by hand after running.
#
# Usage: npm run rename -- <new-slug>
#        bin/rename-theme.sh <new-slug>

set -euo pipefail

if [ "${1:-}" = "" ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	cat <<EOF
Usage: $0 <new-slug>

<new-slug> must be lowercase, dashes-only (no underscores, no spaces).
Example: $0 acme-client
EOF
	exit 1
fi

NEW_SLUG="$1"
OLD_SLUG="wp-starter"

# Validate: lowercase letters, digits, single dashes.
if ! echo "$NEW_SLUG" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
	echo "error: slug must be lowercase, start with a letter, and use dashes only" >&2
	echo "       got: $NEW_SLUG" >&2
	exit 1
fi

if [ "$NEW_SLUG" = "$OLD_SLUG" ]; then
	echo "error: new slug is identical to the current slug ($OLD_SLUG)" >&2
	exit 1
fi

NEW_SNAKE="$(echo "$NEW_SLUG" | tr '-' '_')"
OLD_SNAKE="wp_starter"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Renaming theme:"
echo "  slug:    $OLD_SLUG  →  $NEW_SLUG"
echo "  prefix:  ${OLD_SNAKE}_  →  ${NEW_SNAKE}_"
echo

# -------------------------------------------------------------------------
# Replacement helpers. perl -i is consistent across macOS/Linux.
# -------------------------------------------------------------------------
replace_in() {
	local from="$1"
	local to="$2"
	shift 2
	for f in "$@"; do
		[ -f "$f" ] || continue
		perl -pi -e "s/\Q${from}\E/${to}/g" "$f"
	done
}

# List of files to touch. Keep this narrow — the package manager lockfiles,
# node_modules, vendor, and build outputs must not be rewritten.
TARGETS=()
while IFS= read -r f; do TARGETS+=("$f"); done < <(
	find \
		functions.php style.css composer.json package.json phpcs.xml.dist \
		patterns templates parts \
		-type f \
		\( -name '*.php' -o -name '*.html' -o -name '*.json' -o -name '*.css' -o -name '*.dist' -o -name '*.xml' \) \
		2>/dev/null
)

# 1. Snake-case function prefix. Must run before the dashed-slug pass, since
#    some docblocks contain both (@package wp-starter above a wp_starter_ fn).
#    The `_` form covers function prefixes; the bare form covers phpcs
#    `<element value="wp_starter"/>` and similar whole-word references.
for f in "${TARGETS[@]}"; do
	perl -pi -e "s/\b${OLD_SNAKE}_/${NEW_SNAKE}_/g" "$f"
	perl -pi -e "s/\b${OLD_SNAKE}\b/${NEW_SNAKE}/g" "$f"
done

# 2. Text-domain and pattern-slug references — `wp-starter` as a word boundary
#    (single quotes, double quotes, slashes, spaces).
for f in "${TARGETS[@]}"; do
	# 'wp-starter'      (PHP i18n)
	perl -pi -e "s/'${OLD_SLUG}'/'${NEW_SLUG}'/g" "$f"
	# "wp-starter"      (JSON package names, JSON block attrs)
	perl -pi -e "s/\"${OLD_SLUG}\"/\"${NEW_SLUG}\"/g" "$f"
	# wp-starter/       (pattern slugs: Slug: wp-starter/foo  and  {"slug":"wp-starter/foo"})
	perl -pi -e "s#\b${OLD_SLUG}/#${NEW_SLUG}/#g" "$f"
	# /wp-starter"      (composer vendor/package: "vendor/wp-starter")
	perl -pi -e "s#/${OLD_SLUG}\"#/${NEW_SLUG}\"#g" "$f"
	# wp-starter-       (enqueue handles: 'wp-starter-style' → quoted form handled above, but handle the tail)
	perl -pi -e "s/\b${OLD_SLUG}-/${NEW_SLUG}-/g" "$f"
	# @package wp-starter
	perl -pi -e "s/(\@package\s+)${OLD_SLUG}\b/\$1${NEW_SLUG}/g" "$f"
	# Text Domain: wp-starter   (style.css)
	perl -pi -e "s/(Text Domain:\s*)${OLD_SLUG}\b/\$1${NEW_SLUG}/g" "$f"
	# "the wp-starter theme"    (phpcs.xml.dist description)
	perl -pi -e "s/\bthe ${OLD_SLUG} theme\b/the ${NEW_SLUG} theme/g" "$f"
	# Theme Name: WP Starter    — NOT replaced; project sets this by hand.
done

# 3. phpcs.xml.dist needs both slug (text_domain) and snake (prefix) elements.
#    Those are handled above because both patterns are already applied to
#    phpcs.xml.dist. Confirm by printing what we landed on.
echo "Summary:"
printf "  %-30s %s\n" "functions.php prefixes:" "$(grep -c "${NEW_SNAKE}_" functions.php || true)"
printf "  %-30s %s\n" "pattern slugs on '${NEW_SLUG}':" "$(grep -rE "${NEW_SLUG}/" patterns templates parts 2>/dev/null | wc -l | tr -d ' ')"
printf "  %-30s %s\n" "PHP text domains '${NEW_SLUG}':" "$(grep -rE "'${NEW_SLUG}'" patterns templates functions.php 2>/dev/null | wc -l | tr -d ' ')"

# 4. Verify no stale references remain — but classify URL-style leftovers
#    (template author's GitHub URLs) as expected, since the script cannot
#    know the new project's repo URL.
echo
raw_leftover=$(grep -rn "${OLD_SLUG}\|${OLD_SNAKE}_" \
	--include='*.php' --include='*.html' --include='*.json' --include='*.css' --include='*.xml' --include='*.dist' \
	functions.php style.css composer.json package.json phpcs.xml.dist patterns templates parts 2>/dev/null || true)

# Expected leftovers: URLs pointing at the template's origin repo.
expected=$(printf '%s\n' "$raw_leftover" | grep -E 'https?://|Theme URI|git\+https' || true)
unexpected=$(printf '%s\n' "$raw_leftover" | grep -vE 'https?://|Theme URI|git\+https' | grep -v '^$' || true)

if [ -n "$unexpected" ]; then
	echo "WARNING — unexpected leftovers (these should be zero):"
	printf '%s\n' "$unexpected" | sed 's/^/    /'
	echo
	echo "Please open an issue — the rename script has a gap."
	exit 2
fi

if [ -n "$expected" ]; then
	echo "Expected leftovers (URLs — update these by hand for your project):"
	printf '%s\n' "$expected" | sed 's/^/    /'
	echo
fi

echo "Next manual steps:"
echo "  1. Edit style.css: update Theme Name, Description, Author, Author URI, Tags, Theme URI."
echo "  2. Edit composer.json: update the vendor prefix of the 'name' field if needed."
echo "  3. Edit package.json: update the 'author', 'homepage', 'repository.url', and 'bugs.url' fields."
echo "  4. Rename the theme directory on disk to '${NEW_SLUG}'."
echo "  5. Regenerate .pot/.mo files in languages/ if carried over."
echo "  6. Run 'npm run verify' to confirm nothing drifted."
