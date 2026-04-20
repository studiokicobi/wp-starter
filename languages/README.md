# Translations

Generate / update the `.pot` template via WP-CLI inside `wp-env`:

```bash
npm run env:cli -- i18n make-pot . languages/wp-starter.pot --slug=wp-starter --domain=wp-starter
```

Then replace `wp-starter` everywhere with your project slug (text domain).

Drop `.po` / `.mo` files for target locales alongside `.pot`. WordPress 6.5+
auto-loads bundled translations from this directory via `load_theme_textdomain()`
(called in `functions.php`).
