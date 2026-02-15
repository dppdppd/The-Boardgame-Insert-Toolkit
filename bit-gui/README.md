# BIT GUI

Desktop GUI for constructing Boardgame Insert Toolkit design files.

## Quick Start

```bash
cd bit-gui
npm install
npm run build
npm start
```

## Switching Platforms

The project directory is shared between Windows and Linux. `node_modules` contains platform-specific binaries, so **run `npm install` when switching platforms**. With npm cache this takes ~10 seconds.

## Development

```bash
npm run build    # Build frontend (Vite → dist/)
npm start        # Launch Electron (loads dist/index.html)
```

Rebuild after editing `src/` files.

## Headless Testing (container only)

```bash
xvfb-run -a bash -c '(sleep 3; echo "shot test"; sleep 1; echo quit; sleep 1) | node harness/run.js'
```

Screenshots go to `harness/out/`.
