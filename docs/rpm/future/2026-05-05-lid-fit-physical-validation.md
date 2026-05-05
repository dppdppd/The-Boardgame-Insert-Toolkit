# Add Lid Fit Physical Validation

## Description

Add tolerance-sensitive physical validation for cap, inset, and sliding lids so box/lid combinations warn before producing parts that cannot fit.

## Scope

- Validate cap-lid, inset-lid, and sliding-lid clearances using the generated lid and box dimensions.
- Check lid height, lid wall thickness, frame width, pattern thickness, and tolerance settings as a combined fit.
- Warn when patterned lids or frames conflict with required sliding/inset clearances.
- Cover edge cases where chamber height, wall thickness, or lid position leaves too little printable material.
- Add tests for each lid type with both valid and invalid fit cases.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_lid_frame_width.scad`
- `tests/v4/scad/test_sliding_lid.scad`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Large. This needs careful geometry review because lid variants share parameters but differ in fit behavior.
