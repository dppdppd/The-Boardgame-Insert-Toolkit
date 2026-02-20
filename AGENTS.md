# The Boardgame Insert Toolkit (BIT) — Agent Instructions

## Project Overview

OpenSCAD parametric library for designing 3D-printable board game box inserts with lids.
Users define boxes via key-value data structures; the library renders them into 3D geometry.

- **Language**: OpenSCAD (declarative CSG modeling)
- **Active version**: v4 — `boardgame_insert_toolkit_lib.4.scad`
- **Legacy version**: v3 — archived in `tests/v3-baseline/` (preserved for reference)
- **Helper functions**: `bit_functions_lib.4.scad` (convenience wrappers)
- **Entry point**: User `.scad` files call `Make(data)` which processes a flat data array
- **License**: CC BY-NC-SA 4.0
- **Repo**: https://github.com/dppdppd/The-Boardgame-Insert-Toolkit

## Architecture

### Data Flow
1. User defines a flat data array — globals as `[G_*, value]` pairs, then element entries (OBJECT_BOX, OBJECT_DIVIDERS, OBJECT_SPACER)
2. `Make(data)` extracts globals, filters elements, dispatches to `MakeBox()` or `MakeDividers()` based on type key
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
| `Make()` | Top-level entry, extracts globals, validates keys, dispatches per element |
| `MakeDividers()` | Card dividers with tabs and frames |
| `MakeBox()` / `MakeLayer()` | Box generation + feature processing pipeline |
| `MakeRoundedCubeAxis()` | Rounded cube utility |

### Key Library Sections (boardgame_insert_toolkit_lib.4.scad, ~3,343 lines)
- Lines 46–246: Constants, enums (`SQUARE`, `HEX`, `ROUND`, `FILLET`, `OCT`), defaults
- Lines 247–331: Key-value dictionary helpers (`__index_of_key`, `__value`)
- Lines 646–1160: Key validation (`__ValidateTable`, `__ValidateElement`)
- Lines 1161–1230: **`Make()`** — top-level entry point (extracts globals from data, filters elements)
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

### Test Infrastructure: `tests/v4/`
- `tests/v4/scad/` — 52 test files + symlinks to root `*.4.scad` libs
- `tests/v4/renders/` — PNG renders from test runner and eval tool (gitignored)
- `tests/v4/stl/` — STL exports (gitignored)
- `tests/run_tests.sh` — runs all tests from `tests/v4/scad/`, generates 7 PNG views per test
- Each test includes the lib via symlink: `include <boardgame_insert_toolkit_lib.4.scad>;`

### Regression Baseline: `tests/v3-baseline/`
- `tests/v3-baseline/scad/` — 53 v3-format test files + v3 lib files (self-contained, renderable)
- `tests/v3-baseline/renders/` — historical render output (378 PNGs)
- Library snapshot at commit `0e2e3bb`: `boardgame_insert_toolkit_lib.3.scad`, `bit_functions_lib.3.scad`
- v3 tests use `BOX_COMPONENT`/`CMP_*` keys and `MakeAll()` entry point
- 1-byte STL diffs (0.00%) are acceptable — CGAL floating-point serialization noise

### Test Runner Usage
```bash
./tests/run_tests.sh                              # All tests, all 7 views
./tests/run_tests.sh test_box_minimal              # Single test
./tests/run_tests.sh --views iso,top test_lid_*    # Only iso+top views
./tests/run_tests.sh --csg-only                    # Fast compile check (~7s total)
```
Test files live in `tests/v4/scad/`; the runner discovers them there automatically.

### Evaluation Tool: `tests/render_eval.sh`
```bash
./tests/render_eval.sh tests/v4/scad/test_box_minimal.scad                    # Quick iso + top
./tests/render_eval.sh tests/v4/scad/test_box_minimal.scad --cross-section z,7 # Cross-section
./tests/render_eval.sh tests/v4/scad/test_cutout_sides.scad --views front      # Specific view
./tests/render_eval.sh --inline 'include <boardgame_insert_toolkit_lib.4.scad>;
  data=[
    [G_PRINT_LID_B, false], [G_PRINT_BOX_B, true],
    [OBJECT_BOX, [NAME,"t"],
      [BOX_SIZE_XYZ,[50,50,20]],
      [BOX_FEATURE, [FTR_COMPARTMENT_SIZE_XYZ,[46,46,18]]],
    ],
  ];
  Make(data);'
```
Output goes to `tests/v4/renders/`.

## File Conventions

| Path | Purpose |
|------|---------|
| `*.4.scad` | v4 library files (active) |
| `starter.scad` | Template for new user projects (points at v4) |
| `examples.4.scad` | v4 feature showcase |
| `BIT_*.scad` | User game-specific designs (gitignored) |
| `tests/v4/scad/test_*.scad` | v4 test files (52 total, lib via symlinks) |
| `tests/v4/renders/` | Test suite PNG renders (gitignored) |
| `tests/v4/stl/` | STL exports (gitignored) |
| `tests/v3-baseline/scad/` | v3 test files (53) + v3 libs (self-contained) |
| `tests/v3-baseline/renders/` | Historical render output |
| `tests/render_eval.sh` | Evaluation render tool |
| `tests/run_tests.sh` | Test runner script |

### Test file template
```openscad
// Test: <what this tests>
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "test name" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            // minimal config exercising the feature under test
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
        ],
    ],
];
Make(data);
```

## Visual Editor

The visual editor (BGSD — Board Game Storage Designer) has been split into its own repo:
**[github.com/dppdppd/BGSD](https://github.com/dppdppd/BGSD)**

## CI

CI runs on push/PR to master: Docker OpenSCAD builds `starter.scad` and `examples.4.scad` as STL.

## Code Style

- **OpenSCAD**: Constants/keys in UPPERCASE, modules in PascalCase, 2-space indent
- **Svelte**: Runes syntax (`$state`, `$derived`, `$effect`), kebab-case filenames
- **Git commits**: `type(scope): message` (e.g., `feat:`, `fix:`, `docs:`)

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

### Element-level (inside OBJECT_BOX)
`NAME`, `BOX_SIZE_XYZ`, `BOX_FEATURE`, `BOX_LID`, `BOX_NO_LID_B`, `BOX_STACKABLE_B`, `ENABLED_B`

### Feature-level (inside BOX_FEATURE)
`FTR_COMPARTMENT_SIZE_XYZ`, `FTR_NUM_COMPARTMENTS_XY`, `FTR_SHAPE` (SQUARE/HEX/HEX2/OCT/OCT2/ROUND/FILLET), `FTR_SHAPE_ROTATED_B`, `FTR_SHAPE_VERTICAL_B`, `FTR_PADDING_XY`, `FTR_PADDING_HEIGHT_ADJUST_XY`, `FTR_MARGIN_FBLR`, `FTR_CUTOUT_SIDES_4B`, `FTR_CUTOUT_CORNERS_4B`, `FTR_CUTOUT_HEIGHT_PCT`, `FTR_CUTOUT_DEPTH_PCT`, `FTR_CUTOUT_WIDTH_PCT`, `FTR_CUTOUT_BOTTOM_B`, `FTR_CUTOUT_BOTTOM_PCT`, `FTR_CUTOUT_TYPE` (INTERIOR/EXTERIOR/BOTH), `FTR_SHEAR`, `FTR_FILLET_RADIUS`, `FTR_PEDESTAL_BASE_B`, `POSITION_XY`, `ROTATION`

### Lid-level (inside BOX_LID)
`LID_SOLID_B`, `LID_HEIGHT`, `LID_FIT_UNDER_B`, `LID_INSET_B`, `LID_PATTERN_RADIUS`, `LID_PATTERN_N1/N2`, `LID_PATTERN_ANGLE`, `LID_PATTERN_ROW_OFFSET/COL_OFFSET`, `LID_PATTERN_THICKNESS`, `LID_CUTOUT_SIDES_4B`, `LID_LABELS_INVERT_B`, `LID_SOLID_LABELS_DEPTH`, `LID_LABELS_BG_THICKNESS`, `LID_LABELS_BORDER_THICKNESS`, `LID_STRIPE_WIDTH/SPACE`, `LID_TABS_4B`

### Label-level (inside BOX_LID, BOX_FEATURE, or box-level)
`LBL_TEXT`, `LBL_SIZE` (number or AUTO), `LBL_PLACEMENT` (FRONT/BACK/LEFT/RIGHT/FRONT_WALL/BACK_WALL/LEFT_WALL/RIGHT_WALL/CENTER/BOTTOM), `LBL_FONT`, `LBL_DEPTH`, `LBL_SPACING`, `LBL_IMAGE`, `ROTATION`, `POSITION_XY`

### Divider-level
`DIV_TAB_TEXT`, `DIV_TAB_SIZE_XY`, `DIV_TAB_RADIUS`, `DIV_TAB_CYCLE`, `DIV_TAB_CYCLE_START`, `DIV_TAB_TEXT_SIZE/FONT/SPACING`, `DIV_TAB_TEXT_EMBOSSED_B`, `DIV_FRAME_SIZE_XY`, `DIV_FRAME_NUM_COLUMNS`, `DIV_FRAME_COLUMN`, `DIV_FRAME_TOP/BOTTOM/RADIUS`, `DIV_THICKNESS`

### Globals (as `[G_*, value]` pairs in data array)
`G_PRINT_LID_B`, `G_PRINT_BOX_B`, `G_ISOLATED_PRINT_BOX`, `G_VISUALIZATION_B`, `G_VALIDATE_KEYS_B`, `G_WALL_THICKNESS`, `G_TOLERANCE`, `G_TOLERANCE_DETENT_POS`, `G_DEFAULT_FONT`, `G_PRINT_MMU_LAYER`

File-scope `$g_*` variables provide defaults; data array entries override them via `Make()`.

### Helper functions (bit_functions_lib.4.scad)
`ftr_parms()`, `ftr_parms_fillet()`, `ftr_parms_round()`, `ftr_parms_hex()`, `ftr_parms_hex2()`, `ftr_parms_oct()`, `ftr_parms_oct2()`, `ftr_parms_disc()`, `ftr_parms_hex_tile()`, `lid_parms()`, `lid_parms_solid()`
