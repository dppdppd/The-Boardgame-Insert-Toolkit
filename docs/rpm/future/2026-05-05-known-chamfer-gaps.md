# Resolve Known Chamfer Gaps

## Description

Fix the currently tracked chamfer limitations so `CHAMFER_N` is predictable across compartment grids and supported shape orientations.

## Scope

- Prevent square-cavity top chamfers from eating into partition walls in multi-compartment grids.
- Decide and implement behavior for laid-down hex/oct cavity chamfers, or emit an explicit validation warning when unsupported.
- Preserve manifold-clean STL output and current `CHAMFER_N` surface-width semantics.
- Add targeted render tests for before/after comparison.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_chamfer_n.scad`
- `docs/rpm/present/status.md`

## Estimate

Medium. The square-grid wall cap is likely first; laid-down hex/oct needs design exploration.

## Worker Result

### Summary

Implemented the first narrow slice: square-cavity top opening chamfers now cap sides that face internal grid partitions to half the partition padding minus a tiny clearance. This preserves the existing `CHAMFER_N` surface-width read/conversion semantics while preventing adjacent compartment chamfers from overlapping through the partition wall. Added a focused 2x2 regression model where `CHAMFER_N` is deliberately larger than half the partition width.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_chamfer_partition_cap.scad`
- `docs/rpm/present/status.md`
- `docs/rpm/future/2026-05-05-known-chamfer-gaps.md`

### Verification run

- Pre-edit context: `./tests/run_tests.sh test_chamfer_n` timed out during STL export at 900s after passing the CSG phase.
- `./tests/run_tests.sh --csg-only test_chamfer_n` passed with the existing expected physical-validation warning.
- `./tests/run_tests.sh --csg-only test_chamfer_partition_cap` passed.
- `./tests/run_tests.sh test_chamfer_partition_cap` passed and generated all seven PNG views plus STL under ignored render/STL output directories.
- `timeout 900 openscad -o /tmp/bit_chamfer_partition_cap.stl tests/v4/scad/test_chamfer_partition_cap.scad` passed with `Simple: yes`.
- `./tests/run_tests.sh --csg-only` passed: 74 passed, 0 failed, 18 warnings.

### Remaining risks or follow-ups

- Laid-down hex/oct cavity chamfer behavior remains unresolved and should be handled in a separate slice with either explicit support or a validation warning.
- The existing broad `test_chamfer_n` full STL/render path still exceeds the default 900s timeout in this workspace; the new focused regression provides the required render-backed coverage for this slice.

## Worker Result

### Summary

Implemented the laid-down hex/oct slice as a narrow validation warning rather than new geometry. Laid-down `HEX`, `HEX2`, `OCT`, and `OCT2` cavity chamfers remain unsupported/no-op, but an explicit box- or feature-level `CHAMFER_N > 0` now emits a physical validation warning telling users the cavity chamfer is skipped and suggesting `CHAMFER_N = 0` or `FTR_SHAPE_VERTICAL_B = true`. Default chamfer inheritance stays quiet to avoid warning on normal laid-down shape fixtures that did not explicitly request chamfer behavior.

### Files changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_chamfer_laid_down_warning.scad`
- `docs/rpm/future/2026-05-05-known-chamfer-gaps.md`

### Verification run

- `./tests/run_tests.sh --csg-only test_chamfer_laid_down_warning` passed with the expected unsupported laid-down hex/oct `CHAMFER_N` warnings.
- `openscad -o /tmp/bit_chamfer_laid_down_warning.csg tests/v4/scad/test_chamfer_laid_down_warning.scad` passed and emitted exactly the intended warning cases in the console output.
- `./tests/run_tests.sh --csg-only test_shape_hex test_shape_hex2 test_shape_oct test_shape_oct2` passed with 0 warnings, confirming default laid-down shape fixtures stay quiet.
- `./tests/run_tests.sh --csg-only test_chamfer_n test_chamfer_partition_cap` passed; `test_chamfer_n` retained only its existing overlap warning.
- `./tests/run_tests.sh test_chamfer_laid_down_warning` passed and generated the focused STL plus all seven PNG views under `tests/v4/stl/` and `tests/v4/renders/`.
- `openscad -o /tmp/bit_chamfer_laid_down_warning.stl tests/v4/scad/test_chamfer_laid_down_warning.scad` passed with `Simple: yes`.
- `./tests/run_tests.sh --csg-only` passed: 75 passed, 0 failed, 19 warnings.

### Remaining risks or follow-ups

- No laid-down hex/oct chamfer geometry was added; unsupported cavity chamfers are now explicit only when `CHAMFER_N` is set at the box or feature level.
- If the intended policy is to warn even for the library's implicit default chamfer, a follow-up should remove the explicit-key gate and update normal laid-down shape fixtures or docs for the broader warning surface.
