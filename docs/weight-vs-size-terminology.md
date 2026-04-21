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

## Quick reference

When you read `"medium"` in a block attribute, check the attribute name:

- `fontSize: "medium"` → the size preset under `settings.typography.fontSizes`.
- `fontWeight: "medium"` → the weight preset under `settings.custom.typography.font-weight` (only if you've defined one; WordPress does not ship a built-in weight preset).
- `spacing: { padding: "var:preset|spacing|medium" }` → the spacing preset.

When you write `"medium"`, always prefix the concept in the surrounding prose: *size-medium*, *weight-medium*, *spacing-medium*.
