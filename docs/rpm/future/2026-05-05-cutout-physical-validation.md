# Add Cutout Physical Validation

## Description

Add physical validation for `BOX_CUTOUTS` so designs warn when cutouts make walls, floors, or lid interfaces too fragile.

## Scope

- Validate cutout dimensions and percent-derived dimensions after normalization.
- Warn when cutouts remove too much wall, floor, or top-edge material for the selected side and cutout type.
- Check bottom cutouts for remaining printable floor thickness.
- Check exterior, interior, and both-sided cutouts against box dimensions and wall thickness.
- Keep messages actionable by naming the element, cutout index, parameter, expected range, and computed value.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Medium. Start with axis-aligned rectangular cutouts, then cover rounded and finger-cutout variants.
