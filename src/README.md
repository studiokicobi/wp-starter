# `src/` — theme-bound block source

**Reusable blocks don't belong here.** Build those in a companion plugin so they
survive theme switches. `WordPress.org` guidance:
<https://developer.wordpress.org/block-editor/getting-started/fundamentals/registration-of-a-block/>

Use this directory only for **theme-bound** source (blocks or variations that
only make sense inside *this* theme):

```
src/
└── example-block/
    ├── block.json      # points "editorScript": "file:./index.js" etc.
    ├── edit.js
    ├── save.js
    ├── index.js
    └── style.scss
```

The current starter does **not** auto-discover `src/**/block.json`, generate a
`blocks-manifest.php`, or register blocks from this directory automatically.
Right now the build only compiles the theme's shared frontend assets:

```bash
npm run start   # watch assets/main.js + assets/main.scss → build/
npm run build   # production build for assets/main.js + assets/main.scss → build/
```

If a project later needs theme-bound blocks here, expand the build pipeline and
register the compiled block output from `functions.php` as part of that work.
Until then, treat `src/` as a reserved placeholder rather than a live block
scaffold.
