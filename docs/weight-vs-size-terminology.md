# Weight vs. size terminology

`theme.json` uses the word "Medium" in two unrelated places. If you confuse them, you'll set `fontSize: medium` when you meant `fontWeight: medium` — and the type ramp goes sideways without a console error.

## The ambiguity

| Token | Lives under | Example value | What it controls |
| --- | --- | --- | --- |
| Size preset `medium` | `settings.typography.fontSizes[].slug` | `1.125rem` (or a fluid `{min, max}`) | The font-size CSS property |
| Weight preset `medium` | `settings.custom.typography.font-weight.medium` (if you add one) | `"500"` | The font-weight CSS property |
| Spacing preset `medium` (if present) | `settings.spacing.spacingSizes[].slug` | `1.5rem` | Padding/margin/gap |

They all render as `"Medium"` in the editor's dropdowns. Context is everything.

## Rules for this starter

- **In code comments and docs, always qualify.** Write "size `medium`" or "weight `medium`". Never a bare "medium".
- **In `theme.json`, use distinct slugs where possible.** For weights, prefer named scales (`light`, `regular`, `semibold`, `bold`) rather than numeric sizes that collide with size presets. This starter uses `light` / `normal` under `custom.typography.font-weight` for exactly this reason.
- **In pattern markup, use CSS variable names, not slug strings.** `var(--wp--preset--font-size--medium)` is unambiguous; `"medium"` passed as an attribute is not.
- **In PR descriptions and Slack, same rule.** "Bumped the size-medium preset from 1rem to 1.125rem" is reviewable. "Bumped medium to 1.125rem" sends the reviewer to the wrong place.

## Heading hierarchy is size-only

Every heading (`h1` through `h6`) in `theme.json` renders at weight `normal` via `var(--wp--custom--typography--font-weight--normal)`. Differentiation comes from fluid size presets alone — `colossal` for h1, `gigantic` for h2, and so on down to `small` for h6. There is no "bold h2, medium h3" layer.

**Why.** Weight is an expensive signal. When every heading is bold-by-default, a pattern author who wants emphasis has nowhere left to go. Keeping headings at normal weight preserves bold and strong as *content* affordances that still register on the page. Size is also a cleaner semantic: a reviewer scanning the homepage can compare one heading to another without having to ask whether a visual mismatch is weight drift or size drift.

**How to apply.** When adding a new heading rule to `theme.json` or a block-specific override under `styles.blocks.*`, leave `fontWeight` unset (inherit from the heading element) or set it to the same custom-property reference used on h1–h6. Do not introduce a `bold` or `semibold` weight preset without removing this rule first and noting the reversal in the PR description.

## Quick reference

When you read `"medium"` in a block attribute, check the attribute name:

- `fontSize: "medium"` → the size preset under `settings.typography.fontSizes`.
- `fontWeight: "medium"` → the weight preset under `settings.custom.typography.font-weight` (only if you've defined one; WordPress does not ship a built-in weight preset).
- `spacing: { padding: "var:preset|spacing|medium" }` → the spacing preset.

When you write `"medium"`, always prefix the concept in the surrounding prose: *size-medium*, *weight-medium*, *spacing-medium*.
