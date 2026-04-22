# Deployment

What's different about deploying a site built from this template vs. any other WordPress theme. General WordPress deployment (media, database sync, DNS) is the host's problem; this doc covers the template's own assumptions.

## Before the first deploy

Checklist — all must be true before pushing to a production host:

- [ ] `npm run rename -- <slug>` ran; theme slug is the project's, not `wp-starter`. Verify by grep: `grep -rn "wp-starter" --include="*.php" --include="*.json"` returns nothing unexpected.
- [ ] `style.css` header is project-specific: `Theme Name`, `Description`, `Author`, `Author URI`, `Tags`. The rename script does *not* touch these.
- [ ] `npm run verify` passes locally. CI should run the same script.
- [ ] ACF Pro license is wired — either `ACF_PRO_LICENSE` env var on the host, or a `composer.json` with `auth.json` / `COMPOSER_AUTH`. See [acf-pro-setup.md](acf-pro-setup.md).
- [ ] `WP_ENVIRONMENT_TYPE` is set on the host (`production` on live, `staging` / `development` elsewhere). Plugins and code increasingly branch on this.
- [ ] `build/` contains fresh compiled output. It's committed — don't rely on running `npm run build` on the server.

## What ships

This template commits build artifacts so hosts don't need Node. A deploy is a code sync — git pull, SFTP, rsync — not a build step.

Tracked:

- `build/main.{js,css,asset.php}` — theme bundle
- `build/blocks/<slug>/*` — compiled theme-bound blocks (when any exist)
- `vendor/` — **not** tracked. If the project uses Composer runtime dependencies, run `composer install --no-dev --prefer-dist` once on the host or inside the deploy pipeline.

Not tracked — don't ship these:

- `node_modules/`
- `auth.json`
- `.wp-env.override.json`
- `.env` files of any stripe

## Environment variables

| Variable | Purpose | Where it's read |
| --- | --- | --- |
| `ACF_PRO_LICENSE` | Activates ACF Pro without manual admin click | `wp-config.php` snippet in [acf-pro-setup.md](acf-pro-setup.md) |
| `WP_ENVIRONMENT_TYPE` | Returned by `wp_get_environment_type()` — used for debug banners, caching decisions, block bindings | WordPress core |
| `COMPOSER_AUTH` | ACF Pro Composer endpoint auth in CI (alternative to committing `auth.json`, which is gitignored) | `composer install` |

Most managed hosts expose a UI for setting these. On Kinsta, WP Engine, Pressable, and Cloudways it's under the site's Environment / Config tab. On Pantheon it's `terminus env:info`. On Rocket.net it's under Config → Environment.

## Host-specific notes

### Kinsta, WP Engine, Pressable, Rocket.net

Supports git push-to-deploy. Set up a repository in the host's dashboard, push `main` (or a deploy branch), the host pulls and atomically swaps the theme directory.

Watch for: hosts sometimes run their own asset optimisation (minification, code splitting) on top of what the theme ships. Disable host-level optimisation on `build/main.{js,css}` — it's already minified by `@wordpress/scripts` and re-minifying can break sourcemaps or double-process WordPress dependency externals.

### Pantheon

Code lives on multidev; deploys use `terminus build-env:create`. Composer runs in the Pantheon build pipeline. ACF Pro via the project-level Composer path (not the `.wp-env.override.json` flow — that's local only).

### Cloudways, LocalWP-style self-managed

SSH + git pull. Run `composer install --no-dev` after pull if `composer.json` has runtime deps. `npm run build` is *not* required on the server; the committed `build/` tree is what ships.

### Bedrock / Roots deployments

This template isn't a Bedrock scaffold, but it's compatible: drop the theme directory into `web/app/themes/<slug>/`, point `WP_DEFAULT_THEME` at the slug, and Bedrock's deploy flow handles the rest. All the env-var guidance above applies unchanged.

## CI

The minimum useful CI is `npm run verify` on every PR. GitHub Actions skeleton (paste into `.github/workflows/verify.yml` when a project needs it — *not* committed by default so projects can opt in deliberately):

```yaml
name: verify
on: [pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - uses: shivammathur/setup-php@v2
        with: { php-version: '8.3', tools: composer }
      - run: npm ci
      - run: composer install --prefer-dist --no-progress
      - run: npm run verify
```

For deploys, use the host's recommended flow rather than running `rsync` or `scp` directly — every host has an atomic-swap story that avoids half-deployed states.

## First deploy — step by step

1. **Provision the host.** Fresh WordPress install, admin user created, site URL configured.
2. **Set env vars.** `ACF_PRO_LICENSE`, `WP_ENVIRONMENT_TYPE=production`.
3. **Push code.** Git integration if the host offers it, otherwise SFTP of the theme directory to `wp-content/themes/<slug>/`.
4. **Install Composer deps** (only if the project uses them): `composer install --no-dev --prefer-dist` over SSH.
5. **Activate the theme.** `wp theme activate <slug>` or via wp-admin.
6. **Install and activate ACF Pro** (only if the project uses ACF). `ACF_PRO_LICENSE` handles activation. Verify with `wp plugin list --status=active`.
7. **Flush rewrites.** `wp rewrite flush` — cheap insurance against 404s on custom post types / pattern-driven routes.
8. **Smoke test.** Homepage renders, logged-in admin can edit a pattern, theme's scripts/styles load (`wp-starter-main` in the footer).

## Post-deploy verification

Fast checks that catch the common breakages:

- `curl -sI https://<site>/ | grep -i x-powered-by` — make sure PHP version is 8.3+, matching the repo's floor.
- `curl -s https://<site>/ | grep wp-block-theme` — confirms the theme's body class is present (template is loading).
- `wp option get template` and `wp option get stylesheet` — both should equal the theme slug.
- Editor loads without console errors (browser devtools). Missing block registrations usually show up here first.
- ACF field groups appear under the post type they target.

## Related

- [acf-pro-setup.md](acf-pro-setup.md) — the ACF Pro install recipe this doc references
- [docs/block-authoring.md](block-authoring.md) — how blocks compile into `build/blocks/`
- Repo root [README.md](../README.md) — rename checklist and hosting baseline
