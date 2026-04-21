# WP Starter

A modern Full Site Editing WordPress starter theme with AI agent guardrails baked in.

## What this is

A personal WordPress starter intended to be used as a [GitHub template repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository) for spinning up WordPress client sites. Built on top of [them.es/starter-fse](https://github.com/them-es/starter-fse), with:

- **PHP 8.3+ / WordPress 6.9+ floor** — see "Hosting baseline" below
- `@wordpress/scripts` + SCSS build pipeline
- An intentionally light theme layer that leans on modern block-theme defaults
- `wp-env` for local development (Docker)
- PHPCS (WordPress Coding Standards) + PHPStan (`szepeviktor/phpstan-wordpress`)
- AI agent skills preinstalled in `.claude/skills/` and `.codex/skills/` from the official [WordPress/agent-skills](https://github.com/WordPress/agent-skills) pack
- Repo-level `AGENTS.md` (Codex) and `CLAUDE.md` (Claude Code) to keep agents on modern Gutenberg-era patterns
- A `PostToolUse` hook in `.claude/settings.json` that runs `npm run lint` after Claude edits

## Hosting baseline

**This starter targets modern managed/VPS WordPress hosting and current local dev stacks.** The PHP floor is **8.3**, the WordPress floor is **6.9**.

This is stricter than both WordPress core (which only requires PHP 7.4 in WP 7.0) and the upstream `WordPress/agent-skills` pack (PHP 7.2.24+). That is intentional — the target is Kinsta, WP Engine, Pressable, Pantheon, Rocket.net, Cloudways, and equivalent hosts, plus modern local dev (wp-env, Studio, LocalWP with PHP 8.3+).

**Do not use this template as a base for projects targeting legacy shared hosts.** Fork a different starter for those.

Dependabot alerts on this template currently trace to `@wordpress/*` transitive dependencies — they clear when upstream releases a bump and are safe to accept as-is.

### Tested against

| Package | Version |
| --- | --- |
| `@wordpress/scripts` | `32.0.0` |
| `@wordpress/env` | `11.4.0` |
| WordPress | 6.9 |
| PHP | 8.3 |

## Creating a new project from this template

Enabling and verifying GitHub's **Template repository** flag is a manual repository-settings step on GitHub. Confirm that setting before relying on the **Use this template** flow below.

1. On GitHub, confirm the repository has **Template repository** enabled, then click **"Use this template → Create a new repository"**.
2. Clone the new repo locally into `wp-content/themes/<your-slug>/` (or anywhere, if using `wp-env`).
3. Run the **rename checklist** below *before* writing any project code.
4. `npm install && composer install`.
5. `npm run env:start` to boot a local WordPress at `http://localhost:8888` (admin at `/wp-admin`, user `admin` / password `password`).

## Rename checklist (mandatory on every new project)

The template ships with the slug `wp-starter` everywhere. **Use the rename script** — doing this by hand is error-prone (the rename touches ~9 files including pattern slugs inside PHP).

```bash
npm run rename -- acme-client
```

The script performs the following edits in one pass:

1. **Theme slug** — lowercase, dashes only, no underscores (e.g. `acme-client`, not `acme_client` or `AcmeClient`).
2. **Text domain** = theme slug. Replaces `'wp-starter'` → `'<slug>'` in every PHP i18n call.
3. **Function prefix** — slug converted to `snake_case`. Replaces `wp_starter_` → `<slug_snake>_`.
4. **Pattern slugs** — every `wp-starter/…` pattern slug becomes `<slug>/…` in both pattern headers and template `wp:pattern` references.
5. **`style.css` header** — updates `Text Domain` and `Theme URI`.
6. **`composer.json`** — updates `name` field (`vendor/<slug>`).
7. **`phpcs.xml.dist`** — updates the `text_domain` and `prefixes` properties.
8. **`package.json`** — updates `name` field.

After running, manually review:

- **Directory on disk** — the theme folder name must equal the slug.
- **`style.css`** — `Theme Name`, `Description`, `Author`, `Author URI`, `Tags` are project-specific and not auto-edited.
- **Translation files** — regenerate `.pot` / `.mo` in `languages/` if you carry them over.

Run `npm run verify` afterwards to confirm nothing drifted.

## Scripts

```bash
npm run start          # wp-scripts dev build (watches assets/)
npm run build          # production build
npm run lint           # lint JS (same as lint:js; matches the PostToolUse hook)
npm run lint:js        # lint JS
npm run lint:css       # lint SCSS/CSS
npm run format         # format source/docs (honours .prettierignore)
npm run verify         # block theme standards + lint + phpcs + phpstan
npm run rename -- <slug> # rename the theme slug across every file that references it
npm run env:start      # boot wp-env (latest stable WordPress, theme mounted)
npm run env:stop
npm run env:cli -- ... # run WP-CLI inside wp-env, e.g. `npm run env:cli -- plugin list`

composer phpcs         # PHPCS against WordPress Coding Standards
composer phpcbf        # auto-fix PHPCS issues where possible
composer phpstan       # PHPStan level 6 with WordPress stubs
```

Current build scope: `npm run start` and `npm run build` compile
`assets/main.js` and `assets/main.scss` into `build/`. Theme-bound blocks under
`src/` are optional future scaffolding and are **not** auto-discovered,
manifest-generated, or auto-registered by this starter today.

## AI agents

This repo is set up for two assistants in parallel:

- **Claude Code** reads [CLAUDE.md](CLAUDE.md) and the skills in `.claude/skills/`.
- **Codex** reads [AGENTS.md](AGENTS.md) and the skills in `.codex/skills/`.

### Block theme standards

The agent instructions enforce a nine-item [Technical Contract](CLAUDE.md#block-theme-standards) — tokens, fluid type, template/pattern separation, role-based media, and others. Supporting docs:

- [docs/pattern-composition.md](docs/pattern-composition.md) — how templates, page patterns, and section patterns fit together.
- [docs/media-conventions.md](docs/media-conventions.md) — the role-not-format rule for images, SVGs, and fonts.
- [docs/weight-vs-size-terminology.md](docs/weight-vs-size-terminology.md) — disambiguating "medium" across size, weight, and spacing.
- [docs/conventions.md](docs/conventions.md) — slug substitution, `[PLACEHOLDER]` grammar, and the `TODO(kind):` comment vocabulary.

### Using with an AI agent

The homepage build spec lives at [docs/homepage-build-spec.md](docs/homepage-build-spec.md). Fill the `[…]` fields in the paste-block and hand it to the agent. The spec enforces the Technical Contract and runs `npm run verify` (including the a11y gate) before handing back. It also doubles as human documentation of how the homepage was architected — read it without pasting if you're onboarding onto a project.

Both skill directories were installed from [WordPress/agent-skills](https://github.com/WordPress/agent-skills). To update when new skills ship upstream:

```bash
git clone https://github.com/WordPress/agent-skills.git /tmp/agent-skills
cd /tmp/agent-skills
node shared/scripts/skillpack-build.mjs --clean
node shared/scripts/skillpack-install.mjs \
  --dest=/path/to/this/repo \
  --targets=codex,claude \
  --skills=wordpress-router,wp-project-triage,wp-block-development,wp-block-themes,wp-plugin-development,wp-rest-api,wp-interactivity-api,wp-abilities-api,wp-wpcli-and-ops,wp-performance,wp-phpstan,wp-playground
rm -rf /tmp/agent-skills
```

The installer writes into `.claude/skills/` and `.codex/skills/` at the target's root. Review and commit the diff.

### The `PostToolUse` hook

`.claude/settings.json` runs `scripts/ai-after-edit.sh` after Claude's Edit/Write/MultiEdit tools. The script runs `npm run lint` (JS only — fast). Heavier checks (`build`, `phpcs`, `phpstan`) stay as manual scripts; `CLAUDE.md`'s validation order tells the agent when to run them.

## Project shape

```
wp-starter/
├── AGENTS.md / CLAUDE.md     # agent instructions
├── .claude/
│   ├── settings.json         # PostToolUse lint hook
│   └── skills/               # WordPress/agent-skills (Claude)
├── .codex/
│   └── skills/               # WordPress/agent-skills (Codex)
├── assets/                   # main.js, main.scss — build source
├── build/                    # compiled assets (committed, matches upstream)
├── parts/                    # template parts
├── patterns/                 # starter patterns and template-only content
├── src/                      # optional placeholder for future theme-bound blocks
├── templates/                # FSE templates
├── scripts/
│   └── ai-after-edit.sh      # lint hook
├── theme.json                # v3 — primary styling/config
├── functions.php
├── style.css
├── composer.json
├── phpcs.xml.dist
├── phpstan.neon.dist
├── .wp-env.json
└── package.json
```

Reusable blocks and non-theme-specific features belong in a **separate companion plugin repo**, not in this theme. Themes swap; plugin-registered blocks survive theme changes. That follows [WordPress's own guidance](https://developer.wordpress.org/block-editor/getting-started/fundamentals/registration-of-a-block/) on where custom blocks should live.

## Accessibility

- **Skip link** — every template renders [patterns/a11y-skip-link.php](patterns/a11y-skip-link.php) as its first block, pointing at `#wp--skip-link--target` which is the `id` on every template's `<main>`. Focus styling lives in [assets/main.scss](assets/main.scss). The pattern supersedes WordPress core's automatic skip link so the theme owns the behavior explicitly.
- **Reduced motion** — [assets/main.scss](assets/main.scss) honours `prefers-reduced-motion: reduce` and neutralises animations/transitions for users who request it.
- **Focus styles** — button *and* link `:focus-visible` outlines are defined in [theme.json](theme.json) and inherited by every style variation (see [styles/dark.json](styles/dark.json) for the pattern).
- **Automated a11y gate** — `npm run a11y` is wired into `npm run verify` and **fails by default until the project configures a real tool** (pa11y, axe, lighthouse-ci, etc). This is intentional — new repos must not ship with the a11y check silently passing. Edit the `a11y` script in [package.json](package.json) to point at your chosen tool.

## License

GPL-2.0-or-later. Original starter theme by [them.es](https://them.es/starter-fse/).
