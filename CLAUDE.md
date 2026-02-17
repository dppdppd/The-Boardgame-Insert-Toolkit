# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Boardgame Insert Toolkit (BIT) is a two-part project:
1. **OpenSCAD Library** — parametric CSG library for designing 3D-printable board game box inserts with lids
2. **BIT GUI** — Electron + Svelte desktop app for visually editing BIT `.scad` files

Users define boxes via declarative key-value `data[]` arrays; the library's `MakeAll()` renders them into 3D geometry. The `.scad` file is always the single source of truth.

**Active version: v4** (`boardgame_insert_toolkit_lib.4.scad`). v3 is preserved for hex box users. All new work targets v4 only.

## Common Commands

### OpenSCAD Tests
```bash
./tests/run_tests.sh                          # All 52 tests, 7 PNG views each
./tests/run_tests.sh test_box_minimal          # Single test
./tests/run_tests.sh --csg-only                # Fast compile check (~7s total)
./tests/run_tests.sh --views iso,top test_lid* # Specific views, glob pattern
./tests/render_eval.sh tests/test_box_minimal.scad  # Quick ad-hoc render (iso + top)
```

### BIT GUI
```bash
cd bit-gui
npm install
npm run build          # Vite builds frontend to dist/
npm start              # Launch Electron app
npm run dev            # Watch + launch (concurrent)

# Headless testing via Playwright harness (REPL + screenshots):
xvfb-run -a node harness/run.js
```

### CI
CI runs on push/PR to master: Docker OpenSCAD builds `starter.scad` and `examples.3.scad` as STL.

## Architecture

### OpenSCAD Library Data Flow
1. User defines `data[]` — array of named elements with `[KEY, VALUE]` pairs
2. `MakeAll()` validates keys, dispatches to `MakeBox()` or `MakeDividers()` per element
3. Each box: outer shell → component subtractions → additions → cutouts → lid (CSG pipeline)
4. Output: OpenSCAD geometry exportable as STL

### Key Library Sections (boardgame_insert_toolkit_lib.4.scad, ~3,343 lines)
- Lines 46–246: Constants, enums (`SQUARE`, `HEX`, `ROUND`, `FILLET`, `OCT`), defaults
- Lines 247–331: Key-value dictionary helpers (`__index_of_key`, `__value`)
- Lines 646–1160: Key validation (`__ValidateTable`, `__ValidateElement`)
- Lines 1161–1230: **`MakeAll()`** — top-level entry point
- Lines 1231–1349: `MakeDividers()` — card divider generation
- Lines 1350–1590: `MakeBox()` + `MakeLayer()` — box rendering pipeline
- Lines 2269–2452: `MakeLid()` — lid assembly with patterns

### BIT GUI Architecture

**Tech stack**: Electron 33 + Svelte 5 (runes) + Vite 6 + Playwright (harness)

**Line-based model** — the importer (`bit-gui/importer.js`) parses `.scad` files into `Line` objects preserving every line as-is (kind, depth, role, kvKey/kvValue). This enables round-trip editing with minimal git diff noise.

Key modules:
| Module | Purpose |
|--------|---------|
| `importer.js` | SCAD parser → line-based model (bracket matching, v2/v3 conversion) |
| `src/lib/stores/project.ts` | Svelte store with line mutations (updateKv, deleteLine, insertLine, etc.) |
| `src/lib/schema.ts` | Loads `schema/bit.schema.json`; provides context-aware key lookups |
| `src/lib/scad.ts` | Reconstructs `.scad` from project state |
| `src/lib/autosave.ts` | Debounced file I/O |
| `main.js` | Electron main process (IPC: open/save/OpenSCAD launch) |
| `preload.js` | Context bridge (`window.bitgui` API) |
| `schema/bit.schema.json` | Single source of truth for all parameter types, defaults, enums |

**Schema contexts** (hierarchy): `element` → `component`, `lid`, `label`, `divider`

### GUI Dev Loop
```
1. Edit Svelte components in bit-gui/src/
2. Build: cd bit-gui && npm run build
3. Launch: xvfb-run -a node bit-gui/harness/run.js
4. Drive via REPL: intent + interact (click, type, toggle, wait, shot)
5. Inspect screenshots in bit-gui/harness/out/
```

Harness REPL commands: `shot <label>`, `click <css>`, `type <css> "<text>"`, `toggle <css>`, `wait <css>`, `intent "<text>"`, `act "<intent>" <cmd> <args>`.

Elements use `data-testid` attributes for harness targeting (e.g., `element-N-name`, `kv-KEY-editor`, `add-element`).

## File Conventions

| Pattern | Purpose |
|---------|---------|
| `*.4.scad` | v4 library files (active) |
| `*.3.scad` | v3 library files (legacy) |
| `BIT_*.scad` | User game-specific designs (gitignored) |
| `test_*.scad` | Test files in `tests/` |
| `tests/baseline/` | Pre-refactor v3 snapshot for STL regression |

### Test file template
```openscad
include <../boardgame_insert_toolkit_lib.4.scad>;
include <../bit_functions_lib.4.scad>;
g_default_font = "Liberation Sans:style=Regular";
g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    ["test name", [
        [BOX_SIZE_XYZ, [50, 50, 20]],
        [BOX_COMPONENT, [
            [CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 18]],
        ]]
    ]],
];
MakeAll();
```

## Code Style

- **OpenSCAD**: Constants/keys in UPPERCASE, modules in PascalCase, 2-space indent
- **Svelte**: Runes syntax (`$state`, `$derived`, `$effect`), kebab-case filenames
- **Git commits**: `type(scope): message` (e.g., `feat(bit-gui):`, `fix:`, `docs:`)

## Key Design Decisions

- **SCAD file = source of truth**: GUI preserves user code, comments, and preamble/postamble
- **Schema-driven UI**: All controls generated from `bit.schema.json` — no hardcoded parameter UI
- **Line-based preservation**: Importer classifies lines by kind/role instead of building AST; saves produce minimal diffs
- **Two-phase rendering**: STL export (slow, CGAL) then PNG views (fast, import STL) — separated for efficiency
- **Harness-driven development**: Real app tested headlessly via Playwright; intent pane makes screenshots self-describing
