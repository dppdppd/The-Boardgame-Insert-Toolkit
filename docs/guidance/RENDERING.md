# Rendering & Testing Reference

Detailed CLI commands, camera views, test infrastructure, and file conventions for BIT v4.

## OpenSCAD CLI Quick Reference

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

## 7 Standard Camera Views

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

## Test Infrastructure: `tests/v4/`

- `tests/v4/scad/` — 53 test files + symlink to `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/renders/` — PNG renders from test runner and eval tool (gitignored)
- `tests/v4/stl/` — STL exports (gitignored)
- `tests/run_tests.sh` — runs all tests from `tests/v4/scad/`, generates 7 PNG views per test
- Each test includes the lib via symlink: `include <boardgame_insert_toolkit_lib.4.scad>;`

### Regression Baseline: `tests/v3-baseline/`

- `tests/v3-baseline/scad/` — 53 v3-format test files + v3 lib files (self-contained, renderable)
- `tests/v3-baseline/renders/` — historical render output (231 PNGs)
- Library snapshot at commit `0e2e3bb`: `boardgame_insert_toolkit_lib.3.scad`, `bit_functions_lib.3.scad`
- v3 tests use `BOX_COMPONENT`/`CMP_*` keys and `MakeAll()` entry point
- 1-byte STL diffs (0.00%) are acceptable — CGAL floating-point serialization noise

## Test Runner Usage

```bash
./tests/run_tests.sh                              # All tests, all 7 views
./tests/run_tests.sh test_box_minimal              # Single test
./tests/run_tests.sh --views iso,top test_lid_*    # Only iso+top views
./tests/run_tests.sh --csg-only                    # Fast compile check (~7s total)
```

Test files live in `tests/v4/scad/`; the runner discovers them there automatically.

When adding or changing a test, run that affected test without `--csg-only` before finishing. `--csg-only` is useful as a fast preliminary regression check, but it does not generate STL or PNG files and is not a substitute for render output. Each committed test should have a current render-producing run that writes all requested views to `tests/v4/renders/`.

## Evaluation Tool: `tests/render_eval.sh`

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

**`--cross-section` requires a manifold STL.** The flag works in two passes: first `openscad -o model.stl source.scad`, then `openscad -o slice.stl <import-and-difference>` to slice the exported STL with a half-space cube. CGAL needs a closed mesh for that boolean, so a non-manifold export silently produces a 0-byte slice STL with no error in the script's output (the underlying error `The given mesh is not closed!` is suppressed). If your test triggers this, slice inside the source instead — wrap the model in `intersection() { Make(data); cube([...]); }` so the cut happens before STL export.

## File Conventions

| Path | Purpose |
|------|---------|
| `release/lib/*.4.scad` | v4 library files (active) |
| `release/my_designs/starter.scad` | Template for new user projects (points at v4) |
| `release/my_designs/examples.4.scad` | v4 feature showcase |
| `release/my_designs/BIT_*.scad` | User game-specific designs (gitignored) |
| `tests/v4/scad/test_*.scad` | v4 test files (53 total, lib via symlink) |
| `tests/v4/renders/` | Test suite PNG renders (gitignored) |
| `tests/v4/stl/` | STL exports (gitignored) |
| `tests/v3-baseline/scad/` | v3 test files (53) + v3 libs (self-contained) |
| `tests/v3-baseline/renders/` | Historical render output |
| `tests/render_eval.sh` | Evaluation render tool |
| `tests/run_tests.sh` | Test runner script |

## Test File Template

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
