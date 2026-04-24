# Design system

Contract document between the Figma design and this project's `theme.json`. Fill this in **before** asking Claude Code / Codex to write tokens. If you give an AI assistant raw Figma values, point it at this file so the output lands in the right slots.

## How to use

Open the Figma file and work through the tables below. Fill every slot or mark unused ones `—`. Log any design values that don't fit in the "Conflicts" section at the bottom.

Once complete, hand this file to Claude Code / Codex in Phase 2b to write `theme.json` and (if applicable) `styles/dark.json`.

---

## Colors

The repo ships with **9 fixed palette slots**. `settings.color.custom` is `false`, so every color in the build must resolve to one of these. If the design uses more than 9 distinct colors, see Conflicts.

### Base & contrast

| Slug          | Figma name | Light (hex) | Dark (hex) | Used for                                              |
| ------------- | ---------- | ----------- | ---------- | ----------------------------------------------------- |
| `base`        |            | `#`         | `#`        | Primary page background                               |
| `contrast`    |            | `#`         | `#`        | Strongest text / highest-contrast surfaces            |
| `contrast-2`  |            | `#`         | `#`        | Default body text, default button background, link    |
| `contrast-3`  |            | `#`         | `#`        | Muted text, button hover fill, secondary surfaces     |
| `contrast-4`  |            | `#`         | `#`        | Free slot — tertiary text, branded dark, or unused    |

`contrast-2` and `contrast-3` are load-bearing in the default `styles.elements.button` and `styles.elements.link` rules. If you reassign their roles, update those rules too.

### Accents

| Slug       | Figma name | Light (hex) | Dark (hex) | Role                               |
| ---------- | ---------- | ----------- | ---------- | ---------------------------------- |
| `accent`   |            | `#`         | `#`        | Primary brand accent               |
| `accent-2` |            | `#`         | `#`        | Secondary accent                   |
| `accent-3` |            | `#`         | `#`        | Tertiary accent                    |
| `accent-4` |            | `#`         | `#`        | Quaternary / warning / emphasis    |

Accent slots are ordered but not semantically fixed — pick the ordering that best serves the design. Keep the assignment stable once made; renaming later invalidates pattern markup.

### Dark mode

☐ Dark mode in scope  ☐ Not in scope

If in scope, fill the "Dark (hex)" columns above. Slugs stay identical — only hex values differ.

---

## Typography

### Families (3 slots)

| Slug          | Figma name | Stack                                    |
| ------------- | ---------- | ---------------------------------------- |
| `sans-serif`  |            |                                          |
| `serif`       |            |                                          |
| `monospace`   |            |                                          |

If the design uses only one custom typeface, put it in `sans-serif` and leave the others as system stacks. Body copy defaults to `sans-serif`; headings default to `serif` — update `styles.elements.h1`-`h3` if the design inverts this.

### Sizes (7 slots, fluid)

Fluid typography is **on** (`settings.typography.fluid: true`). Presets above `small` use `{ min, max }` form — `small` is fixed because fluid body text is a pessimization.

| Slug       | Min (rem) | Max (rem) | Used for                                       |
| ---------- | --------- | --------- | ---------------------------------------------- |
| `small`    |           | (fixed)   | Caption, meta, fine print                      |
| `medium`   |           |           | Body copy (default)                            |
| `large`    |           |           | Lead paragraph, H4                             |
| `x-large`  |           |           | H3, pullquote                                  |
| `huge`     |           |           | H3 default                                     |
| `gigantic` |           |           | H2 default, query-title                        |
| `colossal` |           |           | H1 default, post-title                         |

### Line heights (3 slots)

| Slug         | Value | Used for                    |
| ------------ | ----- | --------------------------- |
| `body`       |       | Running text                |
| `heading`    |       | H2-H6                       |
| `page-title` |       | H1, post-title (tighter)    |

### Weights (named slots — expand if needed)

| Slug     | Value | Used for                   |
| -------- | ----- | -------------------------- |
| `light`  |       | Large display headings     |
| `normal` |       | Body, buttons, most headings |

Add more weight slugs (e.g. `medium`, `bold`) here if the design uses them. Keep slug names distinct from size slugs in prose — see `docs/weight-vs-size-terminology.md`.

---

## Spacing (6 slots)

Slugs are numeric (`30`, `40`, `50`, `60`, `70`, `80`) by WordPress convention — they sort correctly in block editor controls. The name column is display-only.

| Slug | Name       | Size (rem) | Used for                              |
| ---- | ---------- | ---------- | ------------------------------------- |
| `30` | Small      |            | Tight gaps, inline block padding      |
| `40` | Medium     |            | Default blockGap, root padding        |
| `50` | Large      |            | Card padding, stack gaps              |
| `60` | X-Large    |            | Section-internal spacing              |
| `70` | 2X-Large   |            | Section padding (top/bottom)          |
| `80` | 3X-Large   |            | Hero padding, large vertical rhythm   |

If the design's spacing scale has more than 6 steps, collapse the ones closest together and log in Conflicts.

---

## Layout

| Setting       | Value | Notes                              |
| ------------- | ----- | ---------------------------------- |
| `contentSize` |       | Default prose width (e.g. `650px`) |
| `wideSize`    |       | Wide-aligned content width         |

Per-section breakpoints aren't in `theme.json` — express responsive layout via block supports (`layout`, `align`) rather than custom CSS.

---

## Radius (5 slots)

| Slug   | Value     | Used for                       |
| ------ | --------- | ------------------------------ |
| `none` | `0`       | Square corners (default button)|
| `sm`   |           | Inputs, small cards            |
| `md`   |           | Cards, panels                  |
| `lg`   |           | Feature cards, media           |
| `pill` | `9999px`  | Pills, tags, round buttons     |

---

## Element defaults

These drive `styles.elements.*` in `theme.json`. Fill in only the values that differ from the repo's current defaults — otherwise the existing values are fine.

### Headings

| Element | Font family | Font size slug | Line-height slug | Weight slug |
| ------- | ----------- | -------------- | ---------------- | ----------- |
| `h1`    |             | `colossal`     | `page-title`     | `normal`    |
| `h2`    |             | `gigantic`     | `heading`        | `normal`    |
| `h3`    |             | `huge`         | `heading`        | `normal`    |
| `h4`    |             | `large`        | `heading`        | `normal`    |
| `h5`    |             | `medium`       | `heading`        | `normal`    |
| `h6`    |             | `small`        | `heading`        | `normal`    |

### Buttons

| State            | Background slug | Text slug | Border radius slug |
| ---------------- | --------------- | --------- | ------------------ |
| Default          | `contrast-2`    | `base`    | `none`             |
| `:hover`         | `contrast-3`    | `base`    | —                  |
| `:focus-visible` | `contrast-3`    | `base`    | outline: `contrast-2` 2px |

If the design's primary button is an accent slot rather than `contrast-2` (common — "our primary button is brand-blue"), update `styles.elements.button` in `theme.json` to match the reassignment, and note the change in Conflicts.

### Links

| State            | Text slug    | Decoration |
| ---------------- | ------------ | ---------- |
| Default          | `contrast-2` | none       |
| `:hover`         | `contrast-2` | underline  |
| `:focus-visible` | —            | outline: `contrast-2` 2px |

### Body

| Property     | Value                              |
| ------------ | ---------------------------------- |
| Font family  | `sans-serif`                       |
| Font size    | `medium`                           |
| Line-height  | `body`                             |
| Background   | `base`                             |
| Text color   | `contrast-2`                       |

---

## Conflicts

Log design values that don't fit the schema and the resolution. Keep this section short — if it's growing past a handful of entries, the design isn't systematic enough and Phase 0 should have caught it.

| Figma value | Fits which slot? | Resolution              |
| ----------- | ---------------- | ----------------------- |
|             |                  |                         |

Resolution options:
- **Collapse** — fold onto an existing slot with a tolerance note
- **Expand** — add a slot (rarely — costs you schema stability)
- **Push back** — ask the designer to reduce the design's token count

---

## Sign-off

☐ All color slots filled or marked `—`  
☐ Type ramp complete, fluid min/max for every preset above `small`  
☐ Spacing scale filled, no orphaned design values  
☐ Layout widths set  
☐ Dark mode fully specified (or marked out of scope)  
☐ Conflicts logged with resolutions  

Completed on: `YYYY-MM-DD` by `<name>`
