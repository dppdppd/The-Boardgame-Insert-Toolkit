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
