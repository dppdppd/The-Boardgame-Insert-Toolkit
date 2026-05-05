# Add Physical Validation For Fit And Printability

## Description

Add validation that catches designs which compile but are physically invalid, fragile, or unlikely to print/fit correctly.

## Scope

- Detect overlapping `BOX_FEATURE` geometry and features extending outside the box.
- Warn on too-thin walls, lid frames, lid pattern struts, cutouts, detents, and divider elements.
- Validate tolerance-sensitive lid/box relationships for cap, inset, and sliding lids.
- Keep warnings actionable: identify the element name, offending parameter, expected range, and computed value.

## Progress

- 2026-05-05: Added first validation slice for thin walls, thin patterned-lid details, too-tall compartments, out-of-bounds unrotated/unsheared component footprints, overlapping unrotated/unsheared component footprints, and thin divider walls.
- 2026-05-05: Added `tests/v4/scad/test_physical_validation.scad` to exercise physical validation messages.

## Remaining

- Remaining validation work is split into follow-up backlog items:
  - `cutout-physical-validation`
  - `detent-physical-validation`
  - `lid-fit-physical-validation`
  - `rotated-sheared-footprint-validation`
  - `validation-enable-flag`

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_key_validation.scad`

## Estimate

Large. Likely best split into validation framework, box/feature bounds checks, then printability thresholds.
