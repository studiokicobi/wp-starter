# ACF Pro setup

How to install Advanced Custom Fields Pro on a project built from this
starter: local `wp-env` flow, production options, and how to avoid
getting silently swapped onto Secure Custom Fields (SCF) from the
WordPress.org directory.

## Don't install from wp-admin's plugin search

Since October 2024, the `advanced-custom-fields` slug on wp.org serves
**Secure Custom Fields** (SCF) — a fork maintained by wp.org
contributors, not the ACF team. SCF has already diverged on features
and release cadence. If you have an ACF Pro license:

1. Install ACF Pro directly from `advancedcustomfields.com` (or via
   Composer, below).
2. Turn off wp.org auto-updates for that plugin so a routine update
   doesn't silently replace it with SCF.

## License activation

ACF Pro reads its license from either:

1. The **License** field under `Settings → ACF` (manual activation), or
2. The `ACF_PRO_LICENSE` PHP constant in `wp-config.php`.

The constant takes precedence and makes the admin setting read-only.
Use it — deploys then don't depend on anyone remembering to click
activate.

Add to `wp-config.php` above the `/* That's all, stop editing! */` line:

```php
// ACF Pro license from environment; keeps the literal key out of the
// file on shared filesystems.
if ( getenv( 'ACF_PRO_LICENSE' ) ) {
	define( 'ACF_PRO_LICENSE', getenv( 'ACF_PRO_LICENSE' ) );
}
```

Set `ACF_PRO_LICENSE` in the host's environment variables (Kinsta, WP
Engine, Pressable all expose a UI for this) or in a per-environment
`.env` file your host's PHP can read.

## Local development (`wp-env`)

Copy the override example and fill in your license:

```bash
cp .wp-env.override.json.example .wp-env.override.json
```

Edit `.wp-env.override.json` — replace both `YOUR_ACF_PRO_LICENSE`
placeholders with your key. The file is gitignored; the license never
enters the repo.

Then rebuild the env:

```bash
npm run env:destroy && npm run env:start
```

What the override does:

- **`plugins`** adds ACF Pro, downloaded on `env:start` from
  `connect.advancedcustomfields.com` using the license as the auth
  token.
- **`config.ACF_PRO_LICENSE`** is piped into the generated
  `wp-config.php` so ACF activates without a manual step.

If `env:start` reports a download failure, your license is invalid or
the ACF endpoint is unreachable — retry, or use the fallback below.

### Fallback: local ZIP

If the direct download URL doesn't behave (some networks intercept the
query string), download the ACF Pro ZIP manually from your account,
drop it at `./plugins/advanced-custom-fields-pro.zip`, and change the
override to:

```json
{
	"plugins": [
		"./plugins/advanced-custom-fields-pro.zip"
	],
	"config": {
		"ACF_PRO_LICENSE": "YOUR_ACF_PRO_LICENSE"
	}
}
```

Add `/plugins/` to `.gitignore` so the ZIP stays local.

## Production

Two paths, pick based on how the project is deployed.

### Option A — project-level Composer

If the project root has a `composer.json` (Bedrock, custom deploys,
some host setups), add ACF's endpoint as a repository and install it as
a dependency:

```json
{
	"repositories": [
		{
			"type": "composer",
			"url": "https://connect.advancedcustomfields.com"
		}
	],
	"require": {
		"wpengine/advanced-custom-fields-pro": "*"
	},
	"extra": {
		"installer-paths": {
			"web/app/plugins/{$name}/": [ "type:wordpress-plugin" ]
		}
	}
}
```

Authentication via an `auth.json` next to `composer.json` (gitignored —
already excluded by this template's `.gitignore`):

```json
{
	"http-basic": {
		"connect.advancedcustomfields.com": {
			"username": "YOUR_LICENSE_KEY",
			"password": "https://your-production-site.com"
		}
	}
}
```

For CI, set the `COMPOSER_AUTH` environment variable instead — same
JSON shape, provided as a single env var:

```bash
COMPOSER_AUTH='{"http-basic":{"connect.advancedcustomfields.com":{"username":"KEY","password":"https://site.com"}}}' \
	composer install --no-dev --prefer-dist
```

### Option B — host-installed plugin

Most managed hosts (Kinsta, WP Engine, Pressable) support uploading a
plugin ZIP via SFTP or dashboard. Upload the ACF Pro ZIP once per
environment; the `ACF_PRO_LICENSE` constant handles activation. No
Composer needed.

## Verify the install

```bash
npm run env:cli -- plugin list --status=active
# advanced-custom-fields-pro    active

npm run env:cli -- eval 'var_dump( defined( "ACF_PRO_LICENSE" ) );'
# bool(true)
```

If the plugin appears but says **Please enter license key** in the
admin, the constant isn't reaching PHP — check the `config` block in
`.wp-env.override.json` and restart `wp-env`.
