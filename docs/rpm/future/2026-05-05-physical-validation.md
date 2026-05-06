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

## Worker Result

Summary: Verified the parent `physical-validation` item is complete as an umbrella task. The current v4 library includes the first physical validation slice for printable wall/detail thresholds, patterned lid detail/frame thresholds, too-tall compartments, unrotated/unsheared feature footprint bounds, unrotated/unsheared feature footprint overlap, and divider thickness. The remaining validation scope is already split into dedicated follow-up backlog items for cutouts, detents, lid fit, rotated/sheared footprints, and the validation enable flag.

Files changed:
- `docs/rpm/future/tasks.org`
- `docs/rpm/future/2026-05-05-physical-validation.md`

Verification run:
- `./tests/run_tests.sh --csg-only test_physical_validation` - passed.
- `openscad -o /tmp/bit_physical_validation_check.csg tests/v4/scad/test_physical_validation.scad` - emitted the expected physical validation messages for wall thickness, lid pattern thickness, lid frame width, too-tall component, out-of-bounds footprint, overlapping components, and divider thickness.
- `./tests/run_tests.sh --csg-only` - 60 passed, 0 failed, 0 warnings.

Remaining risks or follow-ups:
- No further implementation is needed under this parent item.
- The remaining physical validation work should continue through `cutout-physical-validation`, `detent-physical-validation`, `lid-fit-physical-validation`, `rotated-sheared-footprint-validation`, and `validation-enable-flag`.
