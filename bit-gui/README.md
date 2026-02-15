# BIT GUI

Desktop GUI for constructing Boardgame Insert Toolkit design files.

## Quick Start

```bash
cd bit-gui
npm install
npm run build
npm start
```

## Development

```bash
npm run build    # Build frontend (Vite → dist/)
npm start        # Launch Electron (loads dist/index.html)
```

Rebuild after editing `src/` files. `index.html` in root is the Vite source template — open via `npm start`, not directly in a browser.

## Headless Testing (container only)

```bash
xvfb-run -a node harness/run.js
```

Screenshots go to `harness/out/`.
