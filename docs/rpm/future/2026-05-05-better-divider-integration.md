# Improve Divider Integration With Boxes And Generated Layouts

## Description

Make dividers work as part of insert design, not only as separate renderable objects.

## Scope

- Add divider rail grooves inside boxes.
- Support generated divider layouts from card/deck compartment specs.
- Allow divider dimensions to reference matching box or feature dimensions.
- Cover removable dividers, tab clearance, and practical wall/channel tolerances.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_divider_basic.scad`
- `tests/v4/scad/test_divider_advanced.scad`

## Estimate

Medium to large. Start with box divider slots before automatic divider generation.

## 2026-05-06 Status

Moved to `IN-PROGRESS` after validation flag work closed. Start with a design/implementation slice for explicit box divider rail grooves before attempting generated divider layouts.

## First Slice

Implement explicit compartment-local divider rail grooves as an `FTR_DIVIDERS` subgroup inside `BOX_FEATURE`. These should be positive rail pairs on compartment side walls, not negative slits in the floor.

Subgroup keys:
- `FTR_DIVIDERS` inside `BOX_FEATURE`, like `LABEL`, owns the compartment's divider spec.
- `DIV_LAYOUT_BAYS`: number of stored bays along one axis; BIT generates one divider between adjacent bays.
- `DIV_LAYOUT_BAY_SIZE`: physical bay span along the selected axis, in mm. Use `0` for evenly spaced generated dividers.
- `DIV_AXIS`: selected divider axis, `X` or `Y`. Defaults to `X`.
- `DIV_NO_RAILS_B`: when true, suppress matching box-side rail grooves. Defaults to false.
- Divider slot gap is inferred from `DIV_THICKNESS + G_TOLERANCE`.
- Optional `DIV_RAIL_SIZE_XYZ`: positive rail dimensions `[thickness, width, height]`; height may be `MAX` for full compartment height and defaults to `MAX`, so the full default is `[wall_thickness / 2, wall_thickness, MAX]`.
- `G_PRINT_TYPES`: global output selector. Include `DIVIDERS` to print generated divider panels and standalone divider objects, omit it to suppress them, or set `G_PRINT_TYPES` to `DIVIDERS` to print divider output only.
- Existing `DIV_*` keys are valid in the subgroup so the same nested spec can create dividers that fit this compartment.

Current behavior:
- Rail pairs are positive side-wall material and are clipped to the compartment shape.
- Normal `FTR_DIVIDERS` output generates both box rails and loose divider panels, one per requested slot per repeated compartment.
- Preview places generated panels in their slots; render lays generated panels out for printing.
- `G_PRINT_TYPES` can suppress generated panels by omitting `DIVIDERS`, or generate loose divider panels instead of the box/lid by selecting only `DIVIDERS`.
- Generated fitted divider panels are the slot slice intersected with the compartment shape, so non-square cavity profiles produce matching divider edges.
- Fitted panel extents come from the compartment shape and stay within compartment height and side profile; `DIV_TAB_*` tabs are constrained to the fitted divider side span with their top aligned to the compartment top, then the combined divider is clipped to the compartment profile. `DIV_FRAME_*` controls optional frame openings.
- Global exclusive divider output supports iteration and producing extra divider sets without rendering the box body.
- Standalone `OBJECT_DIVIDERS` remains the generic rectangular divider generator.

Out of scope for this slice:
- Automatic matching to `OBJECT_DIVIDERS`.
- Automatic divider layout from card/deck counts.
- Tab-clearance validation.
- Changes to standalone divider STL output beyond preserving its current path.

Implementation should add validation, a focused render test, and preserve the existing `OBJECT_DIVIDERS` path.

First implementation note: the initial worker patch used negative floor slits. That was rejected; the accepted direction is positive side-wall rails that create removable divider grooves while leaving the compartment floor intact.

## Next Executable Plan

The current public layout model uses a single input path:

1. `DIV_LAYOUT_BAYS` is the number of bays along `DIV_AXIS`.
2. `DIV_LAYOUT_BAY_SIZE > 0` places dividers at accumulated physical bay boundaries, centered in the compartment. Required span is `DIV_LAYOUT_BAYS * DIV_LAYOUT_BAY_SIZE + (DIV_LAYOUT_BAYS - 1) * DIV_THICKNESS`.
3. `DIV_LAYOUT_BAY_SIZE == 0` evenly spaces `DIV_LAYOUT_BAYS - 1` generated dividers across the compartment.
4. `DIV_AXIS`, `DIV_NO_RAILS_B`, `DIV_RAIL_SIZE_XYZ`, and `G_PRINT_TYPES` all consume the same generated centerline list after layout resolution.
5. Fitted panel dimensions come from the matching `BOX_FEATURE` compartment. `DIV_FRAME_SIZE_XY` is only for standalone `OBJECT_DIVIDERS`; `DIV_FRAME_*` controls only optional frame openings in generated feature dividers.

## Worker Result - 2026-05-07 - 019e0509-8157-7091-9615-975af4fcb917

Summary: Plan-only result. I inspected `tasks.org`, this detail file, the current `FTR_DIVIDERS` implementation, divider validation, generated panel code, divider tests, and public parameter docs. The first slice is already implemented in the current tree. The remaining generated card/deck layout behavior is ambiguous because the BIT SCAD API currently has no card/deck spec keys to derive from, so I wrote the concrete plan above instead of inventing broad public behavior.

Files changed:
- `docs/rpm/future/2026-05-05-better-divider-integration.md`

Verification:
- Read implementation regions around divider accessors, validation, `MakeDividerSlotRails()`, and `MakeFeatureDividers()`.
- Read focused tests `test_divider_slots.scad`, `test_divider_slots_validation.scad`, `test_divider_compartment_variations.scad`, and `test_divider_print_controls.scad`.
- No CSG/render tests run because no library or test code changed.

Remaining risks/follow-ups:
- Product decision needed on new public layout keys before coding automatic card/deck divider layouts.
- Tab/lid clearance validation should remain a separate narrow slice after layout semantics are settled.

## 2026-05-07 Review Note

Approved the `019e0509-8157-7091-9615-975af4fcb917` plan-written result. The proposed slice is concrete enough to implement after product confirmation: add layout keys, derive divider centerlines from compartment span, document fitted-panel inheritance, and defer tab/lid clearance validation to a separate slice.

## Implementation Result - 2026-05-07 - DIV_LAYOUT keys

Summary: Implemented the approved layout-key slice. `FTR_DIVIDERS` now accepts `DIV_LAYOUT_BAYS` and `DIV_LAYOUT_BAY_SIZE`. The old direct-count and layout-gap keys were removed from the active API. The layout mode derives divider centerlines from the selected compartment axis and requested bay spans, then feeds the same rail, preview, render-layout, selector, and fitted-panel paths. `DIV_LAYOUT_BAY_SIZE` set to `0` evenly spaces the generated dividers. Rail controls now use explicit `DIV_NO_RAILS_B` to suppress rails and `DIV_RAIL_SIZE_XYZ` for rail `[thickness, width, height]`.

Files changed:
- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_divider_layouts.scad`
- `tests/v4/scad/test_divider_slots.scad`
- `tests/v4/scad/test_divider_slots_validation.scad`
- `tests/v4/scad/test_divider_compartment_variations.scad`
- `tests/v4/scad/test_divider_print_controls.scad`
- `tests/v4/scad/test_divider_print_none.scad`
- `tests/v4/scad/test_divider_box_seven_all.scad`
- `docs/rpm/future/2026-05-05-better-divider-integration.md`

Verification:
- `./tests/run_tests.sh --csg-only test_divider_layouts test_divider_slots test_divider_slots_validation test_divider_compartment_variations test_divider_print_controls test_divider_print_none test_divider_box_seven_all` - passed, 7 tests, 0 failures, 1 expected warning-classified validation fixture.
- Rendered changed divider tests and regenerated STL/PNG artifacts: `test_divider_layouts`, `test_divider_slots`, `test_divider_slots_validation`, `test_divider_compartment_variations`, `test_divider_print_controls`, `test_divider_print_none`, and `test_divider_box_seven_all`.
- `./tests/run_tests.sh --csg-only` - passed, 71 tests, 0 failures, 18 warning-classified tests.
- `git diff --check` - passed.
- `rg` over active lib, tests, and docs found no remaining removed divider-count/gap key references.

Remaining risks/follow-ups:
- Tab/lid clearance validation remains a separate slice.
- Layout mode covers uniform bays along one selected axis; variable-size bays would need another explicit public API decision.

## Worker Result - 2026-05-09 - 019e0e16-5c6f-7801-ab12-1584be92393c

Summary: Blocked by parent-thread pause while a direct user request is modifying the same library/docs/tests. I had already made a narrow implementation for generated `FTR_DIVIDERS` physical validation: explicit oversized tab-height requests now warn when fitted generated panels clamp the tab, and generated fitted panels under inset lids warn when their top reaches or lacks tolerance below the lid bottom. Edits are intentionally left in place.

Files changed:
- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_divider_slots_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/2026-05-05-better-divider-integration.md`

Verification run:
- `./tests/run_tests.sh --csg-only test_divider_slots_validation` - passed; warning-classified fixture as expected.
- Manual OpenSCAD CSG compile plus `rg` confirmed the new generated-panel tab clamp and inset-lid clearance warnings appear for the new fixture.
- `./tests/run_tests.sh test_divider_slots_validation` was started for full STL/PNG render verification but interrupted by the pause request; the remaining background render process was stopped.

Remaining risks or follow-ups:
- Full render verification for `test_divider_slots_validation` and full `./tests/run_tests.sh --csg-only` were not completed before the pause.
- Parent-thread changes may overlap these edits; review/rebase against the current library/docs/tests before continuing.

## Completion Note - 2026-05-09

Closed after the generated divider integration shipped and stabilized through `v4.3.0` and `v4.3.1`. The remaining reported BGSD nested object wrapper issue is now tracked as `nested-object-wrapper-degenerate-geometry`.
