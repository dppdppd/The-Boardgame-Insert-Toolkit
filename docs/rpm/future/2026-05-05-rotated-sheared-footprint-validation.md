# Add Rotated And Sheared Footprint Physical Validation

## Description

Extend feature bounds and overlap validation to components with rotation and shear instead of only validating unrotated, unsheared footprints.

## Scope

- Compute conservative XY bounds for rotated component footprints.
- Include shear transforms in bounds checks where the feature pipeline supports them.
- Use conservative overlap warnings to avoid missing impossible layouts while minimizing false positives.
- Preserve the current simple validation path for unrotated, unsheared components.
- Add tests for rotated in-bounds, rotated out-of-bounds, sheared in-bounds, and sheared overlap cases.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_position_rotation.scad`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Medium to large. Rotated AABB validation is likely straightforward; shear requires closer alignment with the rendering pipeline.

## 2026-05-06 Status

Moved to `IN-PROGRESS` after a read-only preparation pass and the lid-fit validation closure. Implementation should add conservative transformed AABB helpers for `ROTATION` and `FTR_SHEAR`, wire them into component bounds and overlap validation, and keep cutout-local physical validation gated to the existing unrotated/unsheared path.

## Completion Note

Closed after adding conservative transformed AABB validation for `ROTATION` and `FTR_SHEAR`. Component bounds and overlap checks now use the transformed footprint; cutout-local validation remains on the existing unrotated/unsheared support path.

Regression coverage:
- `tests/v4/scad/test_rotated_sheared_physical_validation.scad`

Verification:
- Direct `openscad -o /tmp/bit_rotated_sheared_validation.csg tests/v4/scad/test_rotated_sheared_physical_validation.scad` emitted only the expected transformed bounds and overlap warnings.
- `./tests/run_tests.sh --csg-only test_rotated_sheared_physical_validation test_position_rotation test_shear`
- Full CSG suite covered in chunks: 63 test files passed, 0 failed, 0 warnings.
