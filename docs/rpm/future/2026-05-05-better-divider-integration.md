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
- `DIV_NUM_DIVIDERS`: number of evenly spaced generated divider panels on one axis.
- `DIV_AXIS`: selected divider axis, `X` or `Y`. Defaults to `X`.
- `DIV_RAILS_B`: when true, generate matching box-side rail grooves. Defaults to true.
- Divider slot gap is inferred from `DIV_THICKNESS + G_TOLERANCE`.
- Optional `DIV_SLOT_DEPTH`: rail projection into the compartment from the side wall; defaults to wall thickness.
- `DIV_OUTPUT_ONLY_B`: when true, suppresses the parent box/lid and outputs only generated fitted divider panels from output-only subgroups.
- `G_PRINT_DIVIDERS`: global selector for generated divider panels. `true` prints all, `false` prints none, string/list prints matching divider/component/box names.
- `G_PRINT_DIVIDERS_ONLY_B`: global exclusive mode; when true, suppresses boxes/lids and prints only the selected generated divider panels.
- Existing `DIV_*` keys are valid in the subgroup so the same nested spec can create dividers that fit this compartment.

Current behavior:
- Rail pairs are positive side-wall material and are clipped to the compartment shape.
- Normal `FTR_DIVIDERS` output generates both box rails and loose divider panels, one per requested slot per repeated compartment.
- Preview places generated panels in their slots; render lays generated panels out for printing.
- `G_PRINT_DIVIDERS` can suppress generated panels or restrict them to a named subset.
- `G_PRINT_DIVIDERS_ONLY_B` generates selected loose divider panels instead of the box/lid.
- `DIV_OUTPUT_ONLY_B` remains as a per-divider compatibility shortcut for divider-only output.
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
