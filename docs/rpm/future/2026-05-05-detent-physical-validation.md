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
