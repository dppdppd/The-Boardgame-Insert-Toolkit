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

## 2026-05-06 Status

Moved to `IN-PROGRESS` after the cutout-profile task closed. A read-only preparation pass identified this as a validation-only slice: expand `__ValidateLidPhysical()` with box-size context, keep sliding detent validation separate, fold the existing lid-fit-under warning into the lid validator, and add compact cap/inset/sliding cases to `tests/v4/scad/test_physical_validation.scad`.

## Completion Note

Closed after adding cap, inset, and sliding lid fit warnings through `__ValidateLidPhysical()`. The validator now checks generated lid thickness, cap skirt material after tolerance, inset internal/surface spans, sliding raw panel thickness and raw X/Y extents, patterned frame overconsumption, and `LID_FIT_UNDER_B` clearance via `__PhysicalMsg()`.

Verification:
- `./tests/run_tests.sh --csg-only test_physical_validation test_cutout_top_profile`
- Direct `openscad -o /tmp/test_physical_validation.csg tests/v4/scad/test_physical_validation.scad`
- Full CSG suite covered in chunks: 62 test files passed, 0 failed, 0 warnings.
