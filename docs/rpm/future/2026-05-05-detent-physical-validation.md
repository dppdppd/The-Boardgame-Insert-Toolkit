# Add Detent Physical Validation

## Description

Add physical validation for sliding-lid detents so generated rails and stops are printable and fit the lid geometry.

## Scope

- Validate detent thickness, spacing, and distance-from-corner against wall thickness, lid thickness, and box dimensions.
- Warn when detents would be thinner than the minimum printable detail threshold.
- Check detent placement for collisions with corners, cutouts, and sliding-lid grooves where practical.
- Handle disabled or unsupported detent configurations without noisy false positives.
- Add targeted tests for too-thin, too-close, and out-of-range detent configurations.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_sliding_lid.scad`
- `tests/v4/scad/test_physical_validation.scad`

## Estimate

Medium. The first pass can validate parameter relationships before attempting full collision checks.

## Worker Result

### Summary

Added a conservative first pass of physical validation for sliding-lid detents. The new warnings are scoped to enabled sliding lids with enabled numeric detent settings, and cover too-thin detents, detent height clamping against wall/lid thickness, groove material left in the lid panel, cross-axis lid span collapse, requested-length clamping from spacing/corner distance, and generated detents starting too close to cross-axis corners.

The backlog entry remains `IN-PROGRESS` because this does not attempt full collision checks against cutouts or every sliding-lid groove/corner interaction, and it does not extend validation to the legacy cap/inset `MakeDetents` path.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/tasks.org`
- `docs/rpm/future/2026-05-05-detent-physical-validation.md`

### Verification run

- `./tests/run_tests.sh test_physical_validation` - passed; regenerated STL/PNG renders for the changed test.
- `./tests/run_tests.sh --csg-only` - passed, 60 tests.
- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad` - confirmed the new `BIT: physical validation:` sliding detent messages are emitted.

### Remaining risks or follow-ups

- Full collision validation against cutouts, rail grooves, and corner geometry remains to be designed.
- Legacy cap/inset detents were read for context but were not changed in this first pass.
- The checks intentionally skip disabled detents (`G_DETENT_THICKNESS <= 0`) and non-numeric detent globals to avoid noisy physical false positives beyond existing type validation behavior.

## 2026-05-06 Audit Note

Keep this task `IN-PROGRESS`. The `v4.1.0` sliding-lid work added right-triangle detent geometry, matching lid cavities, flat-shelf constraints, and limited cutout collision validation, but the original task still includes broader detent collision/groove/corner coverage and the legacy cap/inset detent path.

## Worker Result

### Summary

Continued the detent validation work with a narrow legacy cap/inset detent slice. Added physical validation for the `MakeDetents` path used by cap and inset lids, covering collapsed/non-positive detent settings, unprintably small effective detent size, invalid spacing/corner/min-spacing values, and detent pair spans that collide with the generated tab/corner span. Sliding detent groove/collision coverage remains unchanged in this pass.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/2026-05-05-detent-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad` - passed; confirmed new cap/inset detent physical validation messages are emitted.
- `./tests/run_tests.sh test_physical_validation` - passed with expected validation warnings; regenerated STL/PNG renders for the changed test.
- `./tests/run_tests.sh --csg-only` - passed, 70 tests, 0 failures.

### Remaining risks or follow-ups

- Broader sliding detent collision/groove/corner validation still needs a separate design pass.
- Legacy cap/inset validation is conservative and parameter/span-based; it does not model exact squished-sphere hull collision volumes.
- Existing default cap/inset lid configurations were kept quiet unless the generated effective detent or corner-to-tab span becomes physically suspect.

## 2026-05-07 Review Note

Approved the legacy cap/inset detent validation slice after source review and focused verification. Keep the parent task `IN-PROGRESS` for the broader sliding-detent collision/groove/corner design pass.

## Worker Result

### Summary

Continued the broader sliding-detent validation with a narrow corner-collision slice. Added a box-`CHAMFER_N` aware physical check for sliding detents that warns when the generated opening-side detent span enters the exterior vertical corner chamfer used by `MakeSlidingLidRailsWithExteriorChamfer`, which would clip the detent even when the basic length/start checks pass. The check is parameter-based, uses the same chamfer conversion as the geometry, and leaves the existing sliding-detent checks active when `CHAMFER_N` itself is malformed.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/2026-05-05-detent-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad` - passed; confirmed the new `sliding detent clipped by chamfer` physical warning is emitted.
- `./tests/run_tests.sh --csg-only test_physical_validation` - passed, 1 expected warning-classified test.
- `./tests/run_tests.sh test_physical_validation` - regenerated `test_physical_validation.stl` and all seven PNG views; the harness exited 141 while printing its warning excerpt, so non-empty STL/PNG outputs were checked separately.
- `find tests/v4/renders tests/v4/stl -maxdepth 1 -type f -name 'test_physical_validation*' -printf '%p %s bytes\n'` - confirmed the regenerated STL and seven PNG renders are non-empty.
- `./tests/run_tests.sh --csg-only` - passed, 70 tests, 0 failures, 22 warning-classified tests.

### Remaining risks or follow-ups

- Broader exact collision validation against all sliding-lid grooves and cutout interactions still needs a separate design pass.
- This slice models the opening-side exterior vertical chamfer clearance from parameters; it does not perform volumetric CSG collision analysis.
- The focused full render harness exit appears to be in the warning-summary output path after renders are generated, not in OpenSCAD geometry generation.

## 2026-05-07 Review Note

Approved the sliding-detent exterior chamfer validation slice after source review. During review, fixed `tests/run_tests.sh` warning-summary pipelines so expected verbose validation output no longer exits with `141` under `pipefail`; focused CSG checks now exit cleanly.

## Plan

Exact volumetric collision checks are not a good fit for the OpenSCAD validation helpers: they can compute parameter-derived spans and emit warnings, but they cannot intersect generated CSG solids and measure the remaining volume. Keep runtime physical validation parameter/AABB based, and reserve true geometry confirmation for focused render/regression tests.

Next executable slices:

1. Centralize sliding-detent envelopes for validation. Add helpers that derive the box detent AABB and matching lid-groove AABB from the same inputs used by `MakeSlidingLidOpeningDetent()` and `MakeSlidingLidDetentGroove()`: slide side, rail side clearance, detent width/height/length, opening-side edge position, and cross-axis span. Acceptance: helper values match the generator formulas for all four `LID_SLIDE_SIDE` values, and existing sliding-lid tests stay quiet except for intentionally invalid cases.

2. Replace the current opening-side cutout collision test with a full parameter AABB overlap check. The check should include cross-axis span, opening-side depth span, vertical overlap against the detent height, `FTR_CUTOUT_TYPE`, custom `G_LID_THICKNESS`, and disabled-detent gating. Acceptance: warn when an exterior/both opening-side side cutout removes a meaningful part of the detent envelope; do not warn for `INTERIOR`, disabled detents, no cross-axis overlap, no opening-side depth overlap, or cutouts that stop below the detent.

3. Add lid-groove envelope fit checks only where they can be derived from current formulas. Validate that the matching groove leaves printable lid skin and has usable width/height after tolerance and panel-thickness clamping; avoid claiming exact groove-volume preservation unless a render test verifies it. Acceptance: targeted physical-validation cases cover collapsed groove width, collapsed groove height, and custom-lid-thickness configurations without adding warnings to normal sliding lids.

4. Add render-backed regression coverage for any remaining exact collision claim. If a future slice needs to prove that chamfers, rail lips, side cutouts, and detents intersect volumetrically as intended, add a focused SCAD test and compare rendered outputs instead of adding speculative runtime warnings. Acceptance: the detail file records which collision is checked by parameter validation and which is checked by render regression.

## Worker Result

### Summary

Implemented Plan slice 1 by centralizing sliding-detent envelope math. Added internal AABB helpers for the generated box detent and matching lid groove, wired the sliding detent validation and generator translations through those helpers, and added assertion coverage proving the helper formulas for all four `LID_SLIDE_SIDE` values. Normal sliding-lid fixtures now set a printable detent thickness so they stay quiet; intentionally invalid physical-validation cases still emit warnings.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `tests/v4/scad/test_lid_sliding.scad`
- `tests/v4/scad/test_lid_sliding_clearance.scad`
- `tests/v4/scad/test_lid_sliding_label.scad`
- `tests/v4/scad/test_lid_frame_width.scad`
- `docs/rpm/future/2026-05-05-detent-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad` - passed; helper assertions for `FRONT`, `BACK`, `LEFT`, and `RIGHT` ran silently.
- `./tests/run_tests.sh --csg-only test_lid_sliding` - passed, 0 warnings.
- `./tests/run_tests.sh --csg-only test_lid_sliding_clearance` - passed, 0 warnings.
- `./tests/run_tests.sh --csg-only test_lid_sliding_label` - passed, 0 warnings.
- `./tests/run_tests.sh --csg-only test_lid_frame_width` - passed, 0 warnings.
- `./tests/run_tests.sh --csg-only test_physical_validation` - passed with expected warning-classified physical-validation output.
- `./tests/run_tests.sh test_lid_sliding test_lid_sliding_clearance test_lid_sliding_label test_physical_validation` - passed; regenerated full render artifacts for those changed tests, with only `test_physical_validation` warning-classified.
- `./tests/run_tests.sh test_lid_frame_width` - passed, 0 warnings; regenerated full render artifacts.
- `./tests/run_tests.sh --csg-only` - passed, 70 tests, 0 failures, 18 warning-classified tests.

### Remaining risks or follow-ups

- This slice centralizes parameter-derived AABBs only; it does not add new cutout/groove collision warnings beyond existing checks.
- The lid-groove AABB is lid-local, while the box-detent AABB is box-local; future overlap checks need an explicit coordinate-space decision before comparing them.
- The broader Plan slices for full opening-side cutout AABB overlap and groove fit checks remain open.

## 2026-05-07 Review Note

Reviewed the older blocked worker result from `019dfaec-44af-7063-acb8-f7f93f28af2e`. It had no claimed code changes; the blocker was valid at the time and was superseded by the later direct detent geometry changes and subsequent approved detent validation slices.

## 2026-05-07 Review Note

Approved the `019e0327-57c6-7da1-8a55-c166cb82d5ce` plan-written result. The plan is concrete, appropriately avoids impossible OpenSCAD volumetric claims, separates runtime AABB validation from render-backed regression coverage, and defines executable acceptance criteria for the remaining sliding-detent validation slices.

## 2026-05-07 Review Note

Approved the `019e0336-0e4b-7d10-9ba7-b3a14b8d7611` implementation slice. The centralized sliding-detent box/groove AABB helpers preserve the existing generator placement formulas for all slide sides, the new assertions cover the helper shape for FRONT/BACK/LEFT/RIGHT, and focused plus full CSG regression checks passed.

## Worker Result

### Summary

Implemented Plan slice 2 by replacing the opening-side sliding-detent cutout warning with a parameter-derived AABB overlap check. The validator now compares the generated box-top detent envelope with the opening-side exterior margin cutout envelope across cross-axis span, opening-side depth span, and detent-height z span. It uses `FTR_CUTOUT_TYPE` gating, respects custom `G_LID_THICKNESS` through the sliding lid height calculation, and stays quiet when sliding detents are disabled.

Added focused physical-validation fixtures for the positive exterior cutout collision and the no-warning cases: `INTERIOR`, disabled detents, no cross-axis overlap, no opening-side depth overlap, and cutouts that stop below the detent.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/2026-05-05-detent-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad` - passed; emitted the new `opening-side side cutout` AABB warning.
- `./tests/run_tests.sh --csg-only test_physical_validation` - passed with expected warning-classified physical-validation output.
- `./tests/run_tests.sh test_physical_validation` - passed; regenerated the changed fixture's STL/PNG render artifacts.
- `./tests/run_tests.sh --csg-only` - passed, 70 tests, 0 failures, 18 warning-classified tests.
- `openscad -o /tmp/bit_physical_validation_check.csg tests/v4/scad/test_physical_validation.scad > /tmp/bit_physical_validation_check.log 2>&1` plus `rg` checks - confirmed exactly one `opening-side side cutout` warning and no detent-cutout warnings for the quiet fixture names.
- `git diff --check` - passed.

### Remaining risks or follow-ups

- The cutout collision check is still AABB based and uses the exterior margin cutout envelope; it does not model the exact rounded cutout profile or perform volumetric CSG intersection.
- Plan slice 3, lid-groove envelope fit checks, remains open.

## 2026-05-07 Review Note

Approved the `019e0478-0111-72c1-a858-cc1a259234e5` implementation slice. The opening-side cutout AABB check correctly gates on exterior/BOTH cutouts, disabled detents, and meaningful overlap across cross/opening/z spans; focused warning-count checks and full CSG regression passed. During review, fixed the remaining warning-summary SIGPIPE path in `tests/run_tests.sh`.

## Worker Result

### Summary

Implemented Plan slice 3 by adding parameter-derived lid-groove envelope fit checks for sliding detents. The validator now derives how the sliding lid bottom bevel clamps the matching groove and warns when usable groove width collapses or when usable groove width/height falls below the printable detail threshold. It keeps the existing lid-skin check and avoids exact groove-volume claims.

Added focused physical-validation fixtures for collapsed matching-groove width, collapsed/thin matching-groove height, and a custom `G_LID_THICKNESS` sliding-detent configuration that stays quiet. Normal sliding-lid fixtures were rechecked and did not gain warnings.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_physical_validation.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/rpm/future/2026-05-05-detent-physical-validation.md`

### Verification run

- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad` - passed; emitted the new matching-groove usable width/height warnings.
- `openscad -o /tmp/bit_physical_validation.csg tests/v4/scad/test_physical_validation.scad > /tmp/bit_physical_validation.log 2>&1` plus `rg` checks - confirmed the custom-lid-thickness fixture stayed quiet and the new groove warning cases were present.
- `./tests/run_tests.sh --csg-only test_physical_validation` - passed with expected warning-classified physical-validation output.
- `./tests/run_tests.sh --csg-only test_lid_sliding` - passed, 0 warnings.
- `./tests/run_tests.sh --csg-only test_lid_sliding_clearance` - passed, 0 warnings.
- `./tests/run_tests.sh --csg-only test_lid_sliding_label` - passed, 0 warnings.
- `./tests/run_tests.sh test_physical_validation` - passed; regenerated the changed fixture's STL/PNG render artifacts.
- `./tests/run_tests.sh --csg-only` - passed, 70 tests, 0 failures, 18 warning-classified tests.
- `git diff --check` - passed.

### Remaining risks or follow-ups

- The new groove checks are formula/AABB based against the lid-local groove and bottom bevel envelope; they do not prove exact retained groove volume.
- Exact chamfer/rail/cutout/detent volumetric claims should still be covered by future render-backed regression tests rather than runtime warnings.

## 2026-05-07 Review Note

Approved the `019e04ed-45cc-7610-8108-015f5f7b1a56` implementation slice. The lid-local groove checks validate the bottom-bevel-clamped usable groove width and height while preserving the existing lid-skin check and avoiding exact-volume claims. Focused log checks confirmed the collapsed width/height warnings are present and the custom-lid-thickness fixture stays quiet; normal sliding-lid CSG fixtures stayed warning-free, and full CSG regression passed with 70 tests, 0 failures, and 18 warning-classified tests.

Runtime detent validation now covers the practical parameter/AABB cases scoped for this task: cap/inset detent sizing, sliding-detent sizing and corner clearance, opening-side cutout AABB overlap, and matching lid-groove fit. No render-backed follow-up is needed for the current warnings because they deliberately avoid exact volumetric claims; future exact collision claims should add render-backed regression coverage before becoming runtime diagnostics.
