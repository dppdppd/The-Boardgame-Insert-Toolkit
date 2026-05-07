# Fix Finger Cutouts Not Cutting Through Sliding Lid Rails

## Description

Finger cutouts on boxes with `LID_TYPE = LID_SLIDING` can fail to cut through the sliding lid rail geometry, leaving rail material where the user expects an open finger access cutout.

## Scope

- Reproduce with a sliding-lid box that has a finger/side cutout reaching the rail area.
- Update the box cutout subtraction path so relevant finger cutouts remove intersecting sliding lid rail material instead of stopping below or behind the rail.
- Preserve normal sliding lid rail/stop geometry when no cutout overlaps it.
- Add targeted regression coverage and regenerate affected renders.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_cutout_breach_thick_wall.scad`
- `tests/v4/scad/test_lid_sliding.scad`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Medium. The tricky part is matching the cutout stencil height and side selection to the sliding rail geometry without over-cutting rails that should remain intact.

## Completion Note

Closed after the `v4.1.0` release. The fix raises the side-cutout stencil through sliding-lid rail geometry for relevant exterior cuts while preserving rails when no cutout overlaps them. Regression coverage lives in `tests/v4/scad/test_lid_sliding_label.scad`, which combines a sliding lid, `FTR_CUTOUT_TYPE = EXTERIOR`, rail-side cutouts, and `FTR_CUTOUT_HEIGHT_PCT = 100`.

Verification:
- `./tests/run_tests.sh test_lid_sliding_label`
- `./tests/run_tests.sh --csg-only`
