# The Boardgame Insert Toolkit (BIT) — Agent Instructions

## Project Overview

OpenSCAD parametric library for designing 3D-printable board game box inserts with lids.
Users define boxes via key-value data structures; the library renders them into 3D geometry.

- **Language**: OpenSCAD (declarative CSG modeling)
- **Active version**: v4 — `boardgame_insert_toolkit_lib.4.scad`
- **Legacy version**: v3 — `boardgame_insert_toolkit_lib.3.scad` (~4,456 lines, preserved for hex box users)
- **Helper functions**: `bit_functions_lib.4.scad` (convenience wrappers)
- **Entry point**: User `.scad` files call `MakeAll()` which processes a `data[]` array
- **License**: CC BY-NC-SA 4.0
- **Repo**: https://github.com/dppdppd/The-Boardgame-Insert-Toolkit

## Architecture

### Data Flow
1. User defines `data[]` — array of named box/divider specs using key-value pairs
2. `MakeAll()` iterates `data[]`, dispatches to `MakeBox()` or `MakeDividers()` based on TYPE
3. Each box goes through layered CSG pipeline: outer shell → feature subtractions → additions → cutouts → lid
4. Output is OpenSCAD geometry exportable as STL

### Key Modules (in boardgame_insert_toolkit_lib.4.scad)
| Module | Purpose |
|--------|---------|
| Constants/Keywords/Defaults | Parameter name constants, shape enums, internal defaults |
| Key-Value Helpers | `__index_of_key()`, `__value()` — dictionary lookup |
| Utility Modules | debug, rotate, mirror, colorize, shear |
| Data Accessors | Extract parameters, auto-size, data with defaults |
| Geometry Helpers | `Make2dShape`, `Make2DPattern`, `MakeStripedGrid` |
| Key Validation | `__ValidateTable`, `__ValidateElement`, type checks |
| `MakeAll()` | Top-level entry, validates keys, dispatches per element |
| `MakeDividers()` | Card dividers with tabs and frames |
| `MakeBox()` / `MakeLayer()` | Box generation + feature processing pipeline |
| `MakeRoundedCubeAxis()` | Rounded cube utility |

### Key Library Sections (boardgame_insert_toolkit_lib.4.scad, ~3,343 lines)
- Lines 46–246: Constants, enums (`SQUARE`, `HEX`, `ROUND`, `FILLET`, `OCT`), defaults
- Lines 247–331: Key-value dictionary helpers (`__index_of_key`, `__value`)
- Lines 646–1160: Key validation (`__ValidateTable`, `__ValidateElement`)
- Lines 1161–1230: **`MakeAll()`** — top-level entry point
- Lines 1231–1349: `MakeDividers()` — card divider generation
- Lines 1350–1590: `MakeBox()` + `MakeLayer()` — box rendering pipeline
- Lines 2269–2452: `MakeLid()` — lid assembly with patterns

### Version History
- **v2**: Legacy, `boardgame_insert_toolkit_lib.2.scad` — no longer maintained
- **v3**: `boardgame_insert_toolkit_lib.3.scad` — includes MakeHexBox, preserved for backward compat
- **v4**: `boardgame_insert_toolkit_lib.4.scad` — MakeHexBox removed, 40% smaller, actively maintained
- **All new work targets v4 only**
- Hex-shaped compartments (HEX, HEX2 via `FTR_SHAPE`) work in v4 — only the hex BOX TYPE was removed

## Rendering & Testing

### Render Pipeline (two-phase for speed)
1. **Phase 1: STL export** — `openscad -o output.stl input.scad` (slow, ~10-600s, CGAL boolean ops)
2. **Phase 2: Multi-view PNG** — Import the STL and render 7 orthographic views (~1s each)

### OpenSCAD CLI Quick Reference
```bash
# CSG export (fast, ~0.3s, compile check only)
openscad -o output.csg input.scad

# STL export (slow, finalized geometry)
openscad -o output.stl input.scad

# PNG from STL (fast, ~1s, finalized + edges overlay)
echo 'import(stl_file);' > /tmp/render.scad
xvfb-run -a openscad --render -o output.png \
  --imgsize=800,600 --autocenter --viewall \
  --projection=ortho --view=edges \
  --camera=0,0,0,55,0,25,0 \
  -D 'stl_file="/path/to/file.stl"' /tmp/render.scad
```

### 7 Standard Camera Views
All use `--projection=ortho --view=edges --autocenter --viewall`:
| View   | Camera (rx,ry,rz) | Shows |
|--------|-------------------|-------|
| top    | 0,0,0             | Compartment layout from above |
| bottom | 180,0,0           | Underside, pedestal bases |
| front  | 90,0,0            | Height profile, front cutouts |
| back   | 90,0,180          | Back cutouts, labels |
| left   | 90,0,90           | Left side features |
| right  | 90,0,270          | Right side features |
| iso    | 55,0,25           | Isometric overview (most informative) |

### Test Infrastructure: `tests/`
- 52 test files covering all box features, combinations, and edge cases
- `tests/run_tests.sh` — runs all tests, generates 7 PNG views per test
- Output: `tests/renders/{test_name}_{view}.png`
- Each test includes the lib via relative path: `include <../boardgame_insert_toolkit_lib.4.scad>;`

### Regression Baseline: `tests/baseline/`
- Contains the **pre-refactor v3** library snapshot (commit `0e2e3bb`) for STL comparison
- Files: `boardgame_insert_toolkit_lib.3.scad` (4,771 lines), `bit_functions_lib.3.scad`
- To run a regression: rewrite test includes to point at baseline v3, render both, compare STL sizes
- 1-byte STL diffs (0.00%) are acceptable — CGAL floating-point serialization noise
- Label-clipped tests may show small size reductions (<5%) — this is correct (invisible geometry removed)

### Test Runner Usage
```bash
./tests/run_tests.sh                              # All tests, all 7 views
./tests/run_tests.sh test_box_minimal              # Single test
./tests/run_tests.sh --views iso,top test_lid_*    # Only iso+top views
./tests/run_tests.sh --csg-only                    # Fast compile check (~7s total)
```

### Evaluation Tool: `tests/render_eval.sh`
```bash
./tests/render_eval.sh tests/test_box_minimal.scad                    # Quick iso + top
./tests/render_eval.sh tests/test_box_minimal.scad --cross-section z,7 # Cross-section
./tests/render_eval.sh tests/test_cutout_sides.scad --views front      # Specific view
./tests/render_eval.sh --inline 'include <boardgame_insert_toolkit_lib.4.scad>;
  data=[["t",[[BOX_SIZE_XYZ,[50,50,20]],
    [BOX_FEATURE,[[FTR_COMPARTMENT_SIZE_XYZ,[46,46,18]]]]]]];
  MakeAll();'
```
Output goes to `tests/renders/eval/`.

## File Conventions

| Path | Purpose |
|------|---------|
| `*.4.scad` | v4 library files (active) |
| `*.3.scad` | v3 library files (legacy, preserved for hex box users) |
| `starter.scad` | Template for new user projects (points at v4) |
| `examples.4.scad` | v4 feature showcase |
| `examples.3.scad` | v3 feature showcase (includes hex box example) |
| `BIT_*.scad` | User game-specific designs (gitignored) |
| `tests/test_*.scad` | Test files (52 total, all reference v4) |
| `tests/baseline/` | Pre-refactor v3 lib snapshot for STL regression |
| `tests/renders/*.png` | Full test suite renders |
| `tests/renders/eval/*.png` | Ad-hoc evaluation renders |
| `tests/render_eval.sh` | Evaluation render tool |
| `tests/run_tests.sh` | Test runner script |
| `BIT_GUI_PLAN.md` | GUI app design & implementation plan |

### Test file template
```openscad
// Test: <what this tests>
include <../boardgame_insert_toolkit_lib.4.scad>;
include <../bit_functions_lib.4.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "test name",
        [
            // minimal config exercising the feature under test
        ]
    ],
];

MakeAll();
```

## BIT GUI

### Architecture

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

**Schema contexts** (hierarchy): `element` → `feature`, `lid`, `label`, `divider`

### Commands
```bash
cd bit-gui
npm install
npm run build          # Vite builds frontend to dist/
npm start              # Launch Electron app
npm run dev            # Watch + launch (concurrent)
```

### Dev Loop
```
1. Edit Svelte components in bit-gui/src/
2. Build: cd bit-gui && npm run build
3. Launch: xvfb-run -a node bit-gui/harness/run.js
4. Drive via REPL: intent + interact (click, type, toggle, wait, shot)
5. Inspect screenshots in bit-gui/harness/out/
```

Elements use `data-testid` attributes for harness targeting (e.g., `element-N-name`, `kv-KEY-editor`, `add-element`).

### Harness

The Playwright harness (`bit-gui/harness/run.js`) drives the Electron app headless for screenshots.

**Prerequisite**: `xvfb` is NOT in the Docker image; install before first use:
```bash
sudo apt-get update && sudo apt-get install -y xvfb
```

**Launch** (interactive REPL):
```bash
cd bit-gui && xvfb-run -a node harness/run.js
```

**Launch** (scripted, non-interactive):
```bash
cd bit-gui && BITGUI_OPEN="../path/to.scad" \
  BITGUI_WINDOW_WIDTH=1920 BITGUI_WINDOW_HEIGHT=1080 \
  BITGUI_HARNESS_COMMANDS=$'wait app-root\nshot label' \
  xvfb-run -a node harness/run.js
```

Screenshots go to `bit-gui/harness/out/` (monotonic counter, never cleared).

Harness REPL commands: `shot <label>`, `click <css>`, `type <css> "<text>"`, `toggle <css>`, `wait <css>`, `intent "<text>"`, `act "<intent>" <cmd> <args>`.

## CI

CI runs on push/PR to master: Docker OpenSCAD builds `starter.scad` and `examples.3.scad` as STL.

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

## Library Refactor Workflow

The `.opencode/` directory contains detailed methodology docs for structured library changes. These were written for the opencode tool but the workflows apply to any agent:

| File | Role |
|------|------|
| `.opencode/skills/bit-refactor/SKILL.md` | Master workflow: ASSESS → PATCH → EVALUATE → UPDATE DOCS → COMMIT |
| `.opencode/agents/bit-assessor.md` | Read cleanup plan + source, produce a patch specification (read-only) |
| `.opencode/agents/bit-patcher.md` | Apply one change, render BEFORE baseline, run CSG regression |
| `.opencode/agents/bit-evaluator.md` | Render AFTER views, compare with BEFORE, verdict: PASS/FAIL/WARN |

Key principles from these docs:
- **One logical change per cycle** — never batch multiple tasks
- **Always render BEFORE baselines** before patching, even for "trivial" changes
- **Refactors must produce identical geometry** — compare BEFORE/AFTER PNGs
- **CSG regression on all tests** after every change (`run_tests.sh --csg-only`)
- **Update docs every cycle** — stale plans are worse than no plan

## Git Workflow

- Branch: `master`
- Remote: `https://github.com/dppdppd/The-Boardgame-Insert-Toolkit.git`
- Push: `GIT_ASKPASS=/home/pa/tmp/git-askpass.sh git push`
- `.gitignore` ignores: `.stl`, `BIT_*.scad`, `*.test.scad`, `old/`, dotfiles (except `.github/`, `.opencode/`), v2 legacy files
- **Tests directory (`tests/`) is NOT gitignored**

## Common Parameters Quick Reference

### Box-level
`BOX_SIZE_XYZ`, `BOX_FEATURE`, `BOX_LID`, `BOX_NO_LID_B`, `BOX_STACKABLE_B`, `ENABLED_B`, `TYPE` (BOX/DIVIDERS)

### Feature-level (inside BOX_FEATURE)
`FTR_COMPARTMENT_SIZE_XYZ`, `FTR_NUM_COMPARTMENTS_XY`, `FTR_SHAPE` (SQUARE/HEX/HEX2/OCT/OCT2/ROUND/FILLET), `FTR_SHAPE_ROTATED_B`, `FTR_SHAPE_VERTICAL_B`, `FTR_PADDING_XY`, `FTR_PADDING_HEIGHT_ADJUST_XY`, `FTR_MARGIN_FBLR`, `FTR_CUTOUT_SIDES_4B`, `FTR_CUTOUT_CORNERS_4B`, `FTR_CUTOUT_HEIGHT_PCT`, `FTR_CUTOUT_DEPTH_PCT`, `FTR_CUTOUT_WIDTH_PCT`, `FTR_CUTOUT_BOTTOM_B`, `FTR_CUTOUT_BOTTOM_PCT`, `FTR_CUTOUT_TYPE` (INTERIOR/EXTERIOR/BOTH), `FTR_SHEAR`, `FTR_FILLET_RADIUS`, `FTR_PEDESTAL_BASE_B`, `POSITION_XY`, `ROTATION`

### Lid-level (inside BOX_LID)
`LID_SOLID_B`, `LID_HEIGHT`, `LID_FIT_UNDER_B`, `LID_INSET_B`, `LID_PATTERN_RADIUS`, `LID_PATTERN_N1/N2`, `LID_PATTERN_ANGLE`, `LID_PATTERN_ROW_OFFSET/COL_OFFSET`, `LID_PATTERN_THICKNESS`, `LID_CUTOUT_SIDES_4B`, `LID_LABELS_INVERT_B`, `LID_SOLID_LABELS_DEPTH`, `LID_LABELS_BG_THICKNESS`, `LID_LABELS_BORDER_THICKNESS`, `LID_STRIPE_WIDTH/SPACE`, `LID_TABS_4B`

### Label-level (inside BOX_LID, BOX_FEATURE, or box-level)
`LBL_TEXT`, `LBL_SIZE` (number or AUTO), `LBL_PLACEMENT` (FRONT/BACK/LEFT/RIGHT/FRONT_WALL/BACK_WALL/LEFT_WALL/RIGHT_WALL/CENTER/BOTTOM), `LBL_FONT`, `LBL_DEPTH`, `LBL_SPACING`, `LBL_IMAGE`, `ROTATION`, `POSITION_XY`

### Divider-level
`DIV_TAB_TEXT`, `DIV_TAB_SIZE_XY`, `DIV_TAB_RADIUS`, `DIV_TAB_CYCLE`, `DIV_TAB_CYCLE_START`, `DIV_TAB_TEXT_SIZE/FONT/SPACING`, `DIV_TAB_TEXT_EMBOSSED_B`, `DIV_FRAME_SIZE_XY`, `DIV_FRAME_NUM_COLUMNS`, `DIV_FRAME_COLUMN`, `DIV_FRAME_TOP/BOTTOM/RADIUS`, `DIV_THICKNESS`

### Globals (set before data[])
`g_b_print_lid`, `g_b_print_box`, `g_isolated_print_box`, `g_b_visualization`, `g_b_validate_keys`, `g_wall_thickness`, `g_tolerance`, `g_tolerance_detents_pos`, `g_default_font`, `g_print_mmu_layer`

### Helper functions (bit_functions_lib.4.scad)
`ftr_parms()`, `ftr_parms_fillet()`, `ftr_parms_round()`, `ftr_parms_hex()`, `ftr_parms_hex2()`, `ftr_parms_oct()`, `ftr_parms_oct2()`, `ftr_parms_disc()`, `ftr_parms_hex_tile()`, `lid_parms()`, `lid_parms_solid()`
