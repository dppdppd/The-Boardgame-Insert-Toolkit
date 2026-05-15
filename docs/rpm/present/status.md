# BIT — Present State

## Project Status
- **Current phase**: v4 stable — incremental feature work and docs maintenance
- **Library version**: `4.10.0`
- **Last updated**: 2026-05-15

## Completed Work
- v4 library shipped as the active version
- v3 archived under `tests/v3-baseline/` (read-only via deny rule)
- Repo reorganized into `release/lib/` and `release/<publisher>/`
- `CHAMFER_N` parameter for exterior edge chamfering; units = chamfer surface diagonal width (perpendicular leg = `CHAMFER_N / sqrt(2)`); default 0.6 mm
- `CHAMFER_N` cavity chamfers fixed for non-square shapes (vertical hex/oct/round) and now also chamfer the cavity opening; manifold-clean STL output
- Square-cavity top `CHAMFER_N` chamfers now cap internal grid-facing sides at half the partition padding so adjacent opening chamfers preserve the partition wall cap.
- Laid-down hex/oct cavity chamfers remain unsupported by geometry, but explicit box/feature `CHAMFER_N > 0` now emits a physical validation warning instead of silently no-oping.
- `release/lib/bit_functions_lib.4.scad` retired (was unused by the engine)
- AGENTS.md consolidated to ~100 lines
- Version-stamping: `scripts/package-release.sh --patch` for bug fixes/internal changes, `--minor` for user-facing features. The pre-commit hook increments patch by default only when the dev lib has changed since the current full-version file; set `BIT_VERSION_BUMP=minor` for feature-release commits.
- Release packaging: `scripts/package-release.sh` writes full-version library files beside the moving dev file in `release/lib/`, updates shipped starter/example includes to the immutable filename, and smoke-compiles shipped entry files.
- `v4.0.8` published on GitHub with `release/lib/boardgame_insert_toolkit_lib.4.0.8.scad` as the first version-locked release asset.
- Sliding lids added via `LID_TYPE = LID_SLIDING`, including configurable slide side, printable 45-degree rail/lid wedge, half-wall bearing shelf, top-open slide entry, and opening-side detent.
- Sliding lid sizing now accounts for rail shelf clearance, `2 * G_TOLERANCE` on each rail side, `G_TOLERANCE` at the stop side, and vertical tolerance above/below the panel.
- `v4.1.0` published on GitHub with `release/lib/boardgame_insert_toolkit_lib.4.1.0.scad` as the version-locked release asset.
- Default wall thickness is now `2.0mm`.
- Sliding lids print right-side-up with a fixed 180-degree print rotation, right-triangle locking detents/grooves, detents constrained to the flat rail shelf after chamfer, and `G_LID_THICKNESS` controlling sliding panel/rail height when set.
- Side finger cutouts at `FTR_CUTOUT_HEIGHT_PCT = 100` now cut through the floor, and `EXTERIOR` side cutouts can breach sliding lid rail geometry.
- Patterned non-solid lids support `LID_FRAME_WIDTH` across cap, inset, and sliding lid types; default is wall thickness, and `0` omits the frame.
- Physical validation first slice added under `G_VALIDATE_KEYS_B`: thin walls/details, component bounds/height, component footprint overlap, and thin divider warnings.
- LLM-friendly design workflow added via `llms.txt`, `.github/copilot-instructions.md`, `docs/llm/`, a generated-design validation script, and a short README prompt for AI chats.
- `v4.2.0` published with generated `FTR_DIVIDERS`, divider print controls, BGSD diagnostic formatting, and sliding-lid fixes.
- `v4.2.1` published with BGSD-compatible physical validation diagnostic prefixes.
- `v4.3.0` published with bay-based divider layout keys, optional rails, refined print/preview placement, and 1600x1200 test render defaults.
- `v4.3.1` published with `DIV_RAIL_SIZE_XYZ` Z defaulting to `MAX`, frame/tab sizing fixes, and divider validation cleanup.
- `v4.4.0` published with `FTR_SHAPE_AXIS` replacing `FTR_SHAPE_ROTATED_B`, BGSD key metadata on physical validation diagnostics, and sliding-detent validation wording cleanup.
- `v4.5.0` published with taller default sliding-lid detents, `LID_DETENT_LOCK_ANGLE` for lid-cavity lock resistance, a 45-degree default lock-side cavity angle, docs, and validation coverage.
- `v4.6.1` published with practical nested `BOX_FEATURE` geometry support and initial transform grouping.
- `v4.7.0` published with transform groups renamed to `FEATURE_GROUP` / `feature_group` and no deprecated `BOX_GROUP` alias.
- `v4.8.0` published with `FEATURE_COPY` / `feature_copy` and `FEATURE_REFERENCE` / `feature_reference` for repeating named features or groups.
- `v4.8.1` published with copied `FEATURE_GROUP` children restored to the group-local negative geometry path.
- `v4.9.0` published with `PRINT_GROUP` / `G_PRINT_GROUP` selection for grouped output of boxes, lids, spacers, standalone dividers, box features, feature groups/copies, and labels. Print groups replace the old MMU-layer switch.
- `v4.9.0` adds `tests/csg_regression.sh` and wires it into the pre-commit hook so normalized CSG for existing v4 tests is compared against `HEAD` before version stamping.
- `v4.9.1` fixes separately printed no-margin feature groups so isolated compartments reserve and emit a wall-thickness rim instead of only base/chamfer helper geometry.
- `v4.10.0` adds stable automatic preview colors for selected print groups and keeps CSG regression focused on geometry by normalizing presentation-only wrappers.

## Active Specs
- No active implementation spec is currently in flight.

## Known Issues
- Nested feature divider print output remains incomplete/experimental; normal nested geometry, labels, and cutouts are supported.
