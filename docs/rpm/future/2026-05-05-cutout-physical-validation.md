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

## Worker Result

### Summary

Added a conservative first slice of `BOX_CUTOUTS` physical validation:

- active side cutout percent controls are checked after normalization, including negative `FTR_CUTOUT_DEPTH_MAX`
- square, axis-aligned side cutouts warn when computed width/depth/height leaves fragile top-edge, rear-depth, or lower-wall material
- square bottom cutouts warn when computed floor thickness or remaining floor rim is below printable thresholds
- validation messages include box/component/cutout context plus computed values and actionable parameter guidance

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/tasks.org`
- `docs/rpm/future/2026-05-05-cutout-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad`
- `./tests/run_tests.sh --csg-only` — 60 passed, 0 failed, 0 warnings
- `./tests/run_tests.sh test_physical_validation` — 1 passed, 0 failed, 0 warnings; regenerated the affected STL and seven PNG renders

### Remaining risks or follow-ups

- Computed fragility checks intentionally skip rotated, sheared, and non-square cutout geometry in this slice.
- Corner cutouts, rounded/finger-specific shape behavior, and lid-interface cutout fragility still need deeper coverage.

## Worker Result

### Summary

Added the next conservative slice for `FTR_CUTOUT_CORNERS_4B`:

- corner cutouts now get physical validation based on the actual `MakeCornerCutouts()` assumptions: fixed 1/4 compartment inset, half padding, and fixed 3mm rounded-cube radius
- messages warn when a selected corner cutout has non-positive spans, interior spans that reach the opposite compartment side, actual cutout spans below the fixed rounded diameter, or paired corner cutouts that overlap / leave a fragile interior bridge
- validation messages include box/component/corner context, computed corner spans, compartment sizes, bridge values, and the relevant size/padding parameters to change

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/2026-05-05-cutout-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad`
- `./tests/run_tests.sh test_physical_validation` — 1 passed, 0 failed, 0 warnings; regenerated `tests/v4/stl/test_physical_validation.stl` and the seven PNG views in `tests/v4/renders/`
- `./tests/run_tests.sh --csg-only` — 60 passed, 0 failed, 0 warnings

### Remaining risks or follow-ups

- The backlog item remains `IN-PROGRESS` because rounded/finger-specific shape behavior, lid-interface cutout fragility, and rotated/sheared cutout validation are still not fully covered.

## Worker Result

### Summary

Added a narrow rounded/finger-specific side-cutout validation slice:

- side cutout validation now mirrors `MakeSideCutouts()` shape selection for `__round_bottom()` and `m_actually_cutout_the_bottom`
- rounded side/finger cutouts warn when the generated fixed 3mm rounded corners cannot fit the computed local spans
- rounded-bottom finger cutouts now skip the rectangular rear-depth fragility checks, because that path switches the rounding axis and those depth assumptions do not match the generated geometry
- `FTR_CUTOUT_BOTTOM_B` validation now treats `FILLET` the same way the generator does: bottom cutouts are ignored for fillet compartments
- Reviewer correction: sliding-lid cutout validation now uses the generator's external lid Z of `2 * wall_thickness`.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/2026-05-05-cutout-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad`
- `./tests/run_tests.sh test_physical_validation` — 1 passed, 0 failed, 0 warnings; regenerated the affected STL and seven PNG renders
- `./tests/run_tests.sh --csg-only` — 60 passed, 0 failed, 0 warnings

### Remaining risks or follow-ups

- The backlog item remains `IN-PROGRESS`.
- General lid-interface cutout fragility is still not covered.
- Rotated/sheared cutout footprint validation remains a separate backlog item.
- This slice validates fixed-radius side cutout spans; it does not redesign or correct the generator's rounded-bottom axis behavior.

## Worker Result

### Summary

Reconciled the remaining `cutout-physical-validation` scope after the approved side, bottom, corner, and rounded/finger slices. The remaining notes do not identify a concrete cutout-only validation gap:

- rotated/sheared cutout footprint handling is intentionally skipped by the current supported-footprint guard and belongs to `rotated-sheared-footprint-validation`
- general lid-interface and tolerance-sensitive lid material checks belong to `lid-fit-physical-validation`; the cutout-specific lid-height coupling already uses the corrected generated lid external Z, including sliding lids
- no additional cutout-only implementation remains after separating those dedicated backlog items

Marked the backlog item `DONE` as complete for cutout-specific physical validation.

### Files changed

- `docs/rpm/future/tasks.org`
- `docs/rpm/future/2026-05-05-cutout-physical-validation.md`

### Verification run

- `./tests/run_tests.sh --csg-only test_physical_validation` - 1 passed, 0 failed, 0 warnings

### Remaining risks or follow-ups

- Continue rotated/sheared footprint work under `rotated-sheared-footprint-validation`.
- Continue general lid-fit and lid-interface material validation under `lid-fit-physical-validation`.
