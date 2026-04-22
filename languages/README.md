# Translations

Generate / update the `.pot` template via WP-CLI inside `wp-env`. Replace
`<slug>` with your project's theme slug (the value set by
`npm run rename -- <slug>`, also in `style.css` Text Domain):

```bash
npm run env:cli -- i18n make-pot . languages/<slug>.pot --slug=<slug> --domain=<slug>
```

Drop `.po` / `.mo` files for target locales alongside `.pot`. WordPress 6.5+
auto-loads bundled translations from this directory via `load_theme_textdomain()`
(called in `functions.php`).
