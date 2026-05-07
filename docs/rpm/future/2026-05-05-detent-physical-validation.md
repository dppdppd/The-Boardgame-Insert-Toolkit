# Add Detent Physical Validation

## Description

Add physical validation for sliding-lid detents so generated rails and stops are printable and fit the lid geometry.

## Scope

- Validate detent thickness, spacing, and distance-from-corner against wall thickness, lid thickness, and box dimensions.
- Warn when detents would be thinner than the minimum printable detail threshold.
- Check detent placement for collisions with corners, cutouts, and sliding-lid grooves where practical.
- Handle disabled or unsupported detent configurations without noisy false positives.
- Add targeted tests for too-thin, too-close, and out-of-range detent configurations.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_sliding_lid.scad`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Medium. The first pass can validate parameter relationships before attempting full collision checks.

## Worker Result

### Summary

Added a conservative first pass of physical validation for sliding-lid detents. The new warnings are scoped to enabled sliding lids with enabled numeric detent settings, and cover too-thin detents, detent height clamping against wall/lid thickness, groove material left in the lid panel, cross-axis lid span collapse, requested-length clamping from spacing/corner distance, and generated detents starting too close to cross-axis corners.

The backlog entry remains `IN-PROGRESS` because this does not attempt full collision checks against cutouts or every sliding-lid groove/corner interaction, and it does not extend validation to the legacy cap/inset `MakeDetents` path.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/tasks.org`
- `docs/rpm/future/2026-05-05-detent-physical-validation.md`

### Verification run

- `./tests/run_tests.sh test_physical_validation` - passed; regenerated STL/PNG renders for the changed test.
- `./tests/run_tests.sh --csg-only` - passed, 60 tests.
- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad` - confirmed the new `BIT: physical validation:` sliding detent messages are emitted.

### Remaining risks or follow-ups

- Full collision validation against cutouts, rail grooves, and corner geometry remains to be designed.
- Legacy cap/inset detents were read for context but were not changed in this first pass.
- The checks intentionally skip disabled detents (`G_DETENT_THICKNESS <= 0`) and non-numeric detent globals to avoid noisy physical false positives beyond existing type validation behavior.

## 2026-05-06 Audit Note

Keep this task `IN-PROGRESS`. The `v4.1.0` sliding-lid work added right-triangle detent geometry, matching lid cavities, flat-shelf constraints, and limited cutout collision validation, but the original task still includes broader detent collision/groove/corner coverage and the legacy cap/inset detent path.
