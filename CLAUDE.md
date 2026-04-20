# CLAUDE.md

This repo is a modern WordPress project. Use the project skills in `.claude/skills/` whenever the task touches WordPress.

## How to work in this repo

Start with classification, then use the matching skill:

- repo detection / setup: `wordpress-router`, `wp-project-triage`
- custom blocks: `wp-block-development`
- block themes / FSE: `wp-block-themes`
- plugin structure / settings / security: `wp-plugin-development`
- REST routes / endpoints: `wp-rest-api`
- permissions / auth / capabilities: `wp-abilities-api`
- interactive frontend behavior in blocks: `wp-interactivity-api`
- WP-CLI / environment / automation: `wp-wpcli-and-ops`
- performance work: `wp-performance`
- PHP static analysis: `wp-phpstan`
- disposable local environments / repros: `wp-playground`

## Repo assumptions

Unless the task says otherwise:

- prefer plugin-first reusable blocks
- use `block.json`
- keep server + client block registration
- use `theme.json` as the primary configuration layer for block themes
- prefer patterns / template parts / supports / style variations over bespoke duplicate code
- prefer the Interactivity API for block-level frontend interactions

## Behavioral rules

- preserve the current package manager and build tooling
- preserve existing architecture unless the task is explicitly architectural
- do not introduce new dependencies casually
- avoid broad refactors
- make small, reviewable edits
- run the most relevant existing validation after edits

## Block-specific rules

When changing a block:
- inspect `block.json` first
- inspect save vs render behavior before editing
- consider attribute compatibility
- consider whether a deprecation is needed
- consider editor and frontend behavior separately
- prefer supports and metadata to custom controls where possible

## Theme-specific rules

When changing a block theme:
- inspect `theme.json` first
- keep design decisions in tokens/settings/styles where practical
- prefer templates, template parts, patterns, and style variations over hardcoded repetition
- avoid scattering styling across many files if `theme.json` or per-block styles are the cleaner home

## Plugin / API rules

When changing plugin code:
- preserve namespace and autoloading patterns already used in the repo
- sanitize input
- escape output
- check capabilities
- include permission callbacks for REST routes
- keep public APIs stable unless the task says otherwise

## Validation order

After edits, run what exists and is relevant:

1. formatting / lint
2. build or typecheck
3. PHP static analysis if present
4. tests if present
5. local WordPress verification if available

If commands are missing or failing because the repo is not configured, state that plainly.

## Communication style

- be direct
- show what changed and why
- mention WordPress-specific consequences such as deprecations, serialization, permissions, or theme.json impact when relevant
- do not over-explain basic code changes