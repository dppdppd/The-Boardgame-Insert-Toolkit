# The Boardgame Insert Toolkit (BIT) — Agent Instructions

## Project Overview

OpenSCAD parametric library for designing 3D-printable board game box inserts with lids.
Users define boxes via key-value data structures; the library renders them into 3D geometry.

- **Language**: OpenSCAD (declarative CSG modeling)
- **Core file**: `boardgame_insert_toolkit_lib.3.scad` (~4,900 lines, the entire engine)
- **Helper functions**: `bit_functions_lib.3.scad` (convenience wrappers)
- **Entry point**: User `.scad` files call `MakeAll()` which processes a `data[]` array
- **License**: CC BY-NC-SA 4.0
- **Repo**: https://github.com/dppdppd/The-Boardgame-Insert-Toolkit

## Architecture

### Data Flow
1. User defines `data[]` — array of named box/divider specs using key-value pairs
2. `MakeAll()` iterates `data[]`, dispatches to `MakeBox()`, `MakeHexBox()`, or `MakeDividers()`
3. Each box goes through layered CSG pipeline: outer shell → component subtractions → additions → cutouts → lid
4. Output is OpenSCAD geometry exportable as STL

### Key Modules (in boardgame_insert_toolkit_lib.3.scad)
| Module | Lines | Purpose |
|--------|-------|---------|
| Constants/Keywords | 1-210 | All parameter name constants and shape enums |
| Key-Value Helpers | 213-216 | `__index_of_key()`, `__value()` — dictionary lookup |
| Data Accessors | 360-445 | Extract parameters from data with defaults |
| `MakeAll()` | 472-527 | Top-level entry, dispatches per element |
| `MakeBox()` | 639-2758 | Rectangular box generation (the big one) |
| `MakeHexBox()` | 2761-4878 | Hexagonal box variant (largely duplicated from MakeBox) |
| `MakeDividers()` | 529-620 | Card dividers with tabs and frames |

### Important: v2 vs v3
- **v3** is the active version: `boardgame_insert_toolkit_lib.3.scad`
- **v2** is legacy: `boardgame_insert_toolkit_lib.2.scad`
- Some old `BIT_*.scad` files still reference v2; these are user projects, not tests
- **All new work targets v3 only**

## Rendering & Testing

### Render Pipeline (two-phase for speed)
The test runner uses a two-phase approach to avoid recomputing CGAL geometry per view:

1. **Phase 1: STL export** — `openscad -o output.stl input.scad` (slow, ~10-600s, CGAL boolean ops)
2. **Phase 2: Multi-view PNG** — Import the STL and render 7 orthographic views (~1s each)

This means 7 views of a test cost only ~1x STL export time + ~7s, vs 7x STL export time.

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
- 53 test files covering all features, combinations, and edge cases
- `tests/run_tests.sh` — runs all tests, generates 7 PNG views per test
- Output: `tests/renders/{test_name}_{view}.png` (371 PNGs total)
- Each test includes the lib via relative path: `include <../boardgame_insert_toolkit_lib.3.scad>;`

### Test Runner Usage
```bash
./tests/run_tests.sh                              # All tests, all 7 views
./tests/run_tests.sh test_box_minimal              # Single test
./tests/run_tests.sh --views iso,top test_lid_*    # Only iso+top views
./tests/run_tests.sh --csg-only                    # Fast compile check (~15s total)
```

### Evaluation Tool: `tests/render_eval.sh`
For targeted inspection during iterative development. Produces only the views
you need, supports cross-sections and wireframes.

```bash
# Quick iso + top after a code change
./tests/render_eval.sh tests/test_box_minimal.scad

# Cross-section to inspect internal wall structure at z=7
./tests/render_eval.sh tests/test_box_minimal.scad --cross-section z,7

# Front view to check cutout depth
./tests/render_eval.sh tests/test_cutout_sides.scad --views front

# Custom camera angle
./tests/render_eval.sh tests/test_shape_hex.scad --camera 30,0,45

# Inline test — no file needed
./tests/render_eval.sh --inline 'include <boardgame_insert_toolkit_lib.3.scad>;
  data=[["t",[[BOX_SIZE_XYZ,[50,50,20]],
    [BOX_COMPONENT,[[CMP_COMPARTMENT_SIZE_XYZ,[46,46,18]]]]]]];
  MakeAll();'
```

Output goes to `tests/renders/eval/`.

## Change Evaluation Process

This is the methodology for making and verifying code changes to the library.

### Step 1: Identify what to verify
Before editing, decide what visible properties the change should affect:

| Change Type | What to Check | Best Views | Technique |
|------------|---------------|------------|-----------|
| Wall thickness | Wall width in cross-section | front, cross-section | `--cross-section x,<center>` |
| Compartment shape | Shape visible from above | top, iso | Default views |
| Cutout depth/width | Cutout visible from the cutout side | front/back/left/right | `--views <side with cutout>` |
| Lid fit / inset | Gap between lid and box | front, cross-section | `--cross-section y,<center> --views front` |
| Label placement | Text on surface | The side the label is on | `--views <label side>` |
| Label depth | How deep text cuts in | cross-section through label | `--cross-section` through text center |
| Pattern generation | Pattern on lid surface | top (lid visible), iso | Default views |
| Stacking fit | Bottom interlocks with lid | front, cross-section at z=wall | `--cross-section z,<wall_thickness>` |
| Detent bumps | Small snap features on walls | front at high zoom | `--views front --imgsize 1600,1200` |
| Pedestal base | Raised platform inside box | cross-section mid-height | `--cross-section z,<half_height>` |
| Tolerance changes | Gap size between lid/box | cross-section through joint | `--cross-section y,<edge>` |
| Fillet radius | Rounding at compartment bottom | cross-section at bottom | `--cross-section z,2` or `--cross-section x,<center>` |

### Step 2: Write or select a test
- For existing features: pick the most relevant test from `tests/test_*.scad`
- For new features: write a minimal `.scad` test that isolates the feature
- Keep tests small — fewer compartments, smaller boxes — for faster STL export

### Step 3: Render BEFORE the change (baseline)
```bash
./tests/render_eval.sh tests/test_<relevant>.scad --views iso,top --name before
```
This saves `tests/renders/eval/before_iso.png` and `before_top.png`.

### Step 4: Make the code change

### Step 5: Render AFTER the change
```bash
./tests/render_eval.sh tests/test_<relevant>.scad --views iso,top --name after
```

### Step 6: Compare
Read both images and verify:
- **Intended change is visible** — the modified feature looks correct
- **No regressions** — nothing else changed unexpectedly
- **Geometry is valid** — no holes, missing faces, or intersecting walls

### Step 7: Run broader regression check
```bash
./tests/run_tests.sh --csg-only  # Fast (~15s): verify all 53 tests still compile
```
Then render a few key tests covering different feature areas:
```bash
./tests/run_tests.sh test_box_minimal test_shape_hex test_lid_solid test_cutout_sides
```

### What to look for in renders

**Good geometry:**
- Clean edges, no stray faces
- Walls have consistent thickness
- Compartments are the right shape and fully open on top
- Lid pattern has even spacing and clean holes
- Labels are readable and correctly positioned

**Bad geometry (indicates a bug):**
- Walls thinner than expected or missing entirely
- Compartments not fully subtracted (solid where hollow expected)
- Z-fighting artifacts (flickering surfaces in preview mode — use `--render`)
- Lid doesn't sit flat or has gaps
- Labels cut through the entire wall instead of just engraving

**Cross-section tells you:**
- Actual wall thickness (compare to `g_wall_thickness`)
- Whether compartments reach the correct depth
- Whether fillets have the right radius
- Whether the lid groove/inset is the right size
- Whether pedestal bases are correctly positioned

### Performance Notes
- Simple tests (no lid, basic shapes): ~6-20s
- Medium tests (with lid, patterns): ~30-90s  
- Complex tests (labels + patterns + cutouts): ~150-600s
- Tests using `bit_functions_lib.3.scad` must define `g_default_font`
- Full suite: ~60 min for all 53 tests
- Cross-sections add one extra STL export (~same as main export time)

## File Conventions

### What lives where
| Path | Purpose |
|------|---------|
| `*.3.scad` | v3 library files (core) |
| `starter.scad` | Template for new user projects |
| `examples.3.scad` | Feature showcase |
| `BIT_*.scad` | User game-specific designs (gitignored) |
| `tests/test_*.scad` | Test files |
| `tests/renders/*.png` | Full test suite renders (7 views each) |
| `tests/renders/eval/*.png` | Ad-hoc evaluation renders |
| `tests/render_eval.sh` | Evaluation render tool (cross-sections, custom views) |
| `tests/run_tests.sh` | Test runner script |
| `images/` | Documentation images |
| `old/` | Archived v1.x files (gitignored) |

### Test file template
```openscad
// Test: <what this tests>
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;

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
- CI: GitHub Actions renders `starter.scad` and `examples.3.scad` via Docker OpenSCAD
- `.gitignore` ignores: `.stl`, `BIT_*.scad`, `*.test.scad`, `old/`, dotfiles (except `.github/`)
- **Tests directory (`tests/`) is NOT gitignored** — tests are part of the project
- Syncthing conflict files (`*_Conflict*`) should be deleted on sight

## Common Parameters Quick Reference

### Box-level
`BOX_SIZE_XYZ`, `BOX_COMPONENT`, `BOX_LID`, `BOX_NO_LID_B`, `BOX_STACKABLE_B`, `ENABLED_B`, `TYPE` (BOX/HEXBOX/DIVIDERS)

### Compartment-level (inside BOX_COMPONENT)
`CMP_COMPARTMENT_SIZE_XYZ`, `CMP_NUM_COMPARTMENTS_XY`, `CMP_SHAPE` (SQUARE/HEX/HEX2/OCT/OCT2/ROUND/FILLET), `CMP_SHAPE_ROTATED_B`, `CMP_SHAPE_VERTICAL_B`, `CMP_PADDING_XY`, `CMP_PADDING_HEIGHT_ADJUST_XY`, `CMP_MARGIN_FBLR`, `CMP_CUTOUT_SIDES_4B`, `CMP_CUTOUT_CORNERS_4B`, `CMP_CUTOUT_HEIGHT_PCT`, `CMP_CUTOUT_DEPTH_PCT`, `CMP_CUTOUT_WIDTH_PCT`, `CMP_CUTOUT_BOTTOM_B`, `CMP_CUTOUT_BOTTOM_PCT`, `CMP_CUTOUT_TYPE` (INTERIOR/EXTERIOR/BOTH), `CMP_SHEAR`, `CMP_FILLET_RADIUS`, `CMP_PEDESTAL_BASE_B`, `POSITION_XY`, `ROTATION`

### Lid-level (inside BOX_LID)
`LID_SOLID_B`, `LID_HEIGHT`, `LID_FIT_UNDER_B`, `LID_INSET_B`, `LID_PATTERN_RADIUS`, `LID_PATTERN_N1/N2`, `LID_PATTERN_ANGLE`, `LID_PATTERN_ROW_OFFSET/COL_OFFSET`, `LID_PATTERN_THICKNESS`, `LID_CUTOUT_SIDES_4B`, `LID_LABELS_INVERT_B`, `LID_SOLID_LABELS_DEPTH`, `LID_LABELS_BG_THICKNESS`, `LID_LABELS_BORDER_THICKNESS`, `LID_STRIPE_WIDTH/SPACE`, `LID_TABS_4B`

### Label-level (inside BOX_LID, BOX_COMPONENT, or box-level)
`LBL_TEXT`, `LBL_SIZE` (number or AUTO), `LBL_PLACEMENT` (FRONT/BACK/LEFT/RIGHT/FRONT_WALL/BACK_WALL/LEFT_WALL/RIGHT_WALL/CENTER/BOTTOM), `LBL_FONT`, `LBL_DEPTH`, `LBL_SPACING`, `LBL_IMAGE`, `ROTATION`, `POSITION_XY`

### Divider-level
`DIV_TAB_TEXT`, `DIV_TAB_SIZE_XY`, `DIV_TAB_RADIUS`, `DIV_TAB_CYCLE`, `DIV_TAB_CYCLE_START`, `DIV_TAB_TEXT_SIZE/FONT/SPACING`, `DIV_FRAME_SIZE_XY`, `DIV_FRAME_NUM_COLUMNS`, `DIV_FRAME_COLUMN`, `DIV_FRAME_TOP/BOTTOM/RADIUS`, `DIV_THICKNESS`

### HexBox-level
`HEXBOX_SIZE_DZ` (replaces BOX_SIZE_XYZ)

### Globals (set before data[])
`g_b_print_lid`, `g_b_print_box`, `g_isolated_print_box`, `g_b_visualization`, `g_wall_thickness`, `g_tolerance`, `g_tolerance_detents_pos`, `g_default_font`, `g_print_mmu_layer`

### Helper functions (bit_functions_lib.3.scad)
`cmp_parms()`, `cmp_parms_fillet()`, `cmp_parms_round()`, `cmp_parms_hex()`, `cmp_parms_hex2()`, `cmp_parms_oct()`, `cmp_parms_oct2()`, `cmp_parms_disc()`, `cmp_parms_hex_tile()`, `lid_parms()`, `lid_parms_solid()`
