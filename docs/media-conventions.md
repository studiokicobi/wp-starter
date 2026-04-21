# Media conventions

Decide by **role**, not by format. `.svg` is a file extension, not an intent. A logo in PNG is still a logo.

## The three roles

| Role | What it is | How to reference it |
| --- | --- | --- |
| Editorial | Imagery chosen per post/page — featured images, in-body photos, gallery assets | Attachment ID via the Media Library |
| Interface | Theme-owned marks that travel with the theme — decorative SVGs, icon marks, pattern backgrounds | `get_theme_file_uri()` from `assets/` |
| Site identity | The logo a site owner can swap without a code deploy | `core/site-logo` block, backed by the Customizer / Site Editor setting |

If you are unsure, ask: *"Would this change if the site owner rebranded without a developer?"* Yes → site identity. No, but the editor picks it per page → editorial. No, it's fixed to the theme build → interface.

## Decision tree

```
Is the asset set once per site and swappable by the site owner?
├─ Yes → core/site-logo
└─ No
    │
    ├─ Does it change per post/page and live in the Media Library?
    │   └─ Yes → attachment ID (editorial)
    │
    └─ Does it ship inside the theme's assets/ folder and travel with the theme?
        └─ Yes → get_theme_file_uri() (interface)
```

## Code by role

### Editorial: attachment ID

Editorial imagery must resolve through the Media Library so editors can swap it, attach alt text, and benefit from responsive `srcset`.

```php
<!-- wp:image {"id":123,"sizeSlug":"large"} -->
<figure class="wp-block-image size-large">
    <?php echo wp_get_attachment_image( 123, 'large' ); ?>
</figure>
<!-- /wp:image -->
```

In patterns, prefer the block markup so the editor sees a real `core/image` block — not a raw `<img>`.

### Interface: `get_theme_file_uri()`

Theme-owned assets (icon marks, decorative SVGs, pattern backgrounds) live in `assets/` and ship with the theme.

```php
<!-- wp:image {"className":"is-style-decor"} -->
<figure class="wp-block-image is-style-decor">
    <img
        src="<?php echo esc_url( get_theme_file_uri( 'assets/decor/wave.svg' ) ); ?>"
        alt=""
        role="presentation"
    />
</figure>
<!-- /wp:image -->
```

Rules:
- Always `esc_url()` the output of `get_theme_file_uri()`.
- Decorative imagery uses `alt=""` and `role="presentation"`.
- Do not hotlink; do not base64-inline SVGs in markup (caches poorly, bloats pattern output).

### Site identity: `core/site-logo`

The site logo is never hardcoded — even if the current value happens to be an SVG in the theme.

```html
<!-- wp:site-logo {"width":120} /-->
```

If the theme needs a fallback visual when no logo is set, render it via CSS or a pattern variant — do not inline the fallback in the site-logo markup.

## Fonts

Fonts are theme-owned interface assets. Register them via `theme.json` `settings.typography.fontFamilies[].fontFace[].src`, pointing at `file:./assets/fonts/...`. Never enqueue a font stylesheet from `functions.php` when `theme.json` can register it.

## Anti-patterns

- Hardcoded `<img src="/wp-content/themes/...">` — the theme slug changes on rename. Use `get_theme_file_uri()`.
- Attachment ID for a logo — breaks `core/site-logo`.
- `get_theme_file_uri()` for an editorial photo — editors cannot change it.
- Inline base64 SVG in a pattern — bloats every render; breaks caching.
