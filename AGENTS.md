# The Boardgame Insert Toolkit (BIT) — Agent Instructions

## Project Overview

OpenSCAD parametric library for designing 3D-printable board game box inserts with lids.
Users define boxes via key-value data structures; the library renders them into 3D geometry.

- **Language**: OpenSCAD (declarative CSG modeling)
- **Active version**: v4 — `boardgame_insert_toolkit_lib.4.scad` (~2,675 lines)
- **Legacy version**: v3 — `boardgame_insert_toolkit_lib.3.scad` (~4,456 lines, preserved for hex box users)
- **Helper functions**: `bit_functions_lib.4.scad` (convenience wrappers)
- **Entry point**: User `.scad` files call `MakeAll()` which processes a `data[]` array
- **License**: CC BY-NC-SA 4.0
- **Repo**: https://github.com/dppdppd/The-Boardgame-Insert-Toolkit

## Architecture

### Data Flow
1. User defines `data[]` — array of named box/divider specs using key-value pairs
2. `MakeAll()` iterates `data[]`, dispatches to `MakeBox()` or `MakeDividers()` based on TYPE
3. Each box goes through layered CSG pipeline: outer shell → component subtractions → additions → cutouts → lid
4. Output is OpenSCAD geometry exportable as STL

### Key Modules (in boardgame_insert_toolkit_lib.4.scad)
| Module | Lines | Purpose |
|--------|-------|---------|
| Constants/Keywords/Defaults | 1-230 | Parameter name constants, shape enums, internal defaults |
| Key-Value Helpers | 241-250 | `__index_of_key()`, `__value()` — dictionary lookup |
| Utility Modules | 325-380 | debug, rotate, mirror, colorize, shear |
| Data Accessors | 382-500 | Extract parameters from data with defaults |
| Geometry Helpers | 501-580 | `Make2dShape`, `Make2DPattern`, `MakeStripedGrid` |
| `MakeAll()` | 585-635 | Top-level entry, dispatches per element |
| `MakeDividers()` | 641-750 | Card dividers with tabs and frames |
| `MakeBox()` | 763-2610 | Box generation (single module, no hex variant) |
| `MakeLayer()` | 901-2608 | Component processing pipeline (inside MakeBox) |
| `MakeRoundedCubeAxis()` | 2617-2670 | Rounded cube utility |

### Version History
- **v2**: Legacy, `boardgame_insert_toolkit_lib.2.scad` — no longer maintained
- **v3**: `boardgame_insert_toolkit_lib.3.scad` — includes MakeHexBox, preserved for backward compat
- **v4**: `boardgame_insert_toolkit_lib.4.scad` — MakeHexBox removed, 40% smaller, actively maintained
- **All new work targets v4 only**
- Hex-shaped compartments (HEX, HEX2 via `CMP_SHAPE`) work in v4 — only the hex BOX TYPE was removed

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
- 50 test files covering all box features, combinations, and edge cases
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
    [BOX_COMPONENT,[[CMP_COMPARTMENT_SIZE_XYZ,[46,46,18]]]]]]];
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
| `tests/test_*.scad` | Test files (50 total, all reference v4) |
| `tests/baseline/` | Pre-refactor v3 lib snapshot for STL regression |
| `tests/renders/*.png` | Full test suite renders |
| `tests/renders/eval/*.png` | Ad-hoc evaluation renders |
| `tests/render_eval.sh` | Evaluation render tool |
| `tests/run_tests.sh` | Test runner script |
| `CLEANUP_PLAN.md` | Refactor plan with task status |

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

## Git Workflow

- Branch: `master`
- Remote: `https://github.com/dppdppd/The-Boardgame-Insert-Toolkit.git`
- Push: `GIT_ASKPASS=/home/pa/tmp/git-askpass.sh git push`
- `.gitignore` ignores: `.stl`, `BIT_*.scad`, `*.test.scad`, `old/`, dotfiles (except `.github/`, `.opencode/`), v2 legacy files
- **Tests directory (`tests/`) is NOT gitignored**

## Common Parameters Quick Reference

### Box-level
`BOX_SIZE_XYZ`, `BOX_COMPONENT`, `BOX_LID`, `BOX_NO_LID_B`, `BOX_STACKABLE_B`, `ENABLED_B`, `TYPE` (BOX/DIVIDERS)

### Compartment-level (inside BOX_COMPONENT)
`CMP_COMPARTMENT_SIZE_XYZ`, `CMP_NUM_COMPARTMENTS_XY`, `CMP_SHAPE` (SQUARE/HEX/HEX2/OCT/OCT2/ROUND/FILLET), `CMP_SHAPE_ROTATED_B`, `CMP_SHAPE_VERTICAL_B`, `CMP_PADDING_XY`, `CMP_PADDING_HEIGHT_ADJUST_XY`, `CMP_MARGIN_FBLR`, `CMP_CUTOUT_SIDES_4B`, `CMP_CUTOUT_CORNERS_4B`, `CMP_CUTOUT_HEIGHT_PCT`, `CMP_CUTOUT_DEPTH_PCT`, `CMP_CUTOUT_WIDTH_PCT`, `CMP_CUTOUT_BOTTOM_B`, `CMP_CUTOUT_BOTTOM_PCT`, `CMP_CUTOUT_TYPE` (INTERIOR/EXTERIOR/BOTH), `CMP_SHEAR`, `CMP_FILLET_RADIUS`, `CMP_PEDESTAL_BASE_B`, `POSITION_XY`, `ROTATION`

### Lid-level (inside BOX_LID)
`LID_SOLID_B`, `LID_HEIGHT`, `LID_FIT_UNDER_B`, `LID_INSET_B`, `LID_PATTERN_RADIUS`, `LID_PATTERN_N1/N2`, `LID_PATTERN_ANGLE`, `LID_PATTERN_ROW_OFFSET/COL_OFFSET`, `LID_PATTERN_THICKNESS`, `LID_CUTOUT_SIDES_4B`, `LID_LABELS_INVERT_B`, `LID_SOLID_LABELS_DEPTH`, `LID_LABELS_BG_THICKNESS`, `LID_LABELS_BORDER_THICKNESS`, `LID_STRIPE_WIDTH/SPACE`, `LID_TABS_4B`

### Label-level (inside BOX_LID, BOX_COMPONENT, or box-level)
`LBL_TEXT`, `LBL_SIZE` (number or AUTO), `LBL_PLACEMENT` (FRONT/BACK/LEFT/RIGHT/FRONT_WALL/BACK_WALL/LEFT_WALL/RIGHT_WALL/CENTER/BOTTOM), `LBL_FONT`, `LBL_DEPTH`, `LBL_SPACING`, `LBL_IMAGE`, `ROTATION`, `POSITION_XY`

### Divider-level
`DIV_TAB_TEXT`, `DIV_TAB_SIZE_XY`, `DIV_TAB_RADIUS`, `DIV_TAB_CYCLE`, `DIV_TAB_CYCLE_START`, `DIV_TAB_TEXT_SIZE/FONT/SPACING`, `DIV_FRAME_SIZE_XY`, `DIV_FRAME_NUM_COLUMNS`, `DIV_FRAME_COLUMN`, `DIV_FRAME_TOP/BOTTOM/RADIUS`, `DIV_THICKNESS`

### Globals (set before data[])
`g_b_print_lid`, `g_b_print_box`, `g_isolated_print_box`, `g_b_visualization`, `g_wall_thickness`, `g_tolerance`, `g_tolerance_detents_pos`, `g_default_font`, `g_print_mmu_layer`

### Helper functions (bit_functions_lib.4.scad)
`cmp_parms()`, `cmp_parms_fillet()`, `cmp_parms_round()`, `cmp_parms_hex()`, `cmp_parms_hex2()`, `cmp_parms_oct()`, `cmp_parms_oct2()`, `cmp_parms_disc()`, `cmp_parms_hex_tile()`, `lid_parms()`, `lid_parms_solid()`
