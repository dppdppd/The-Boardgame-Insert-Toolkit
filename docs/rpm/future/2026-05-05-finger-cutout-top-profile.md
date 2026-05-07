# Fix Finger Cutout Top Profile Looking Like Two Pills

## Description

Some finger cutouts render with a top profile that looks like two pill-shaped lobes instead of a single clean finger access profile. This likely comes from the rounded cutout shape, height, or hull logic creating separate rounded regions at the top edge.

## Scope

- Reproduce the two-pill top profile with a focused side/finger cutout test case.
- Identify whether the issue comes from rounded-bottom finger geometry, standard side cutout rounding, or interaction with lid/rail cutout height.
- Adjust the cutout shape generation so the visible top profile is a single clean finger cutout.
- Add or update regression coverage and regenerate affected renders.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_cutout_sides.scad`
- `tests/v4/scad/test_cutout_breach_thick_wall.scad`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Medium. Requires visual confirmation because the bug is primarily profile quality, not just CSG compilation.

## 2026-05-06 Status

Moved to `IN-PROGRESS` after the `v4.1.0` release audit. The next implementation pass should isolate the rounded side-cutout generation path and add visual regression coverage for the single clean top profile.

## Completion Note

Closed after replacing the rounded-bottom side cutout primitive with a vertical 2D finger profile extruded into the wall. The lower edge remains rounded while the visible top profile stays continuous instead of being rounded into separate pill-like lobes.

Regression coverage:
- `tests/v4/scad/test_cutout_top_profile.scad`

Verification:
- `./tests/run_tests.sh --csg-only test_cutout_top_profile test_lid_sliding_label`
- Generated front, back, top, and iso renders show a single continuous profile.
