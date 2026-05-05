# BIT — Present State

## Project Status
- **Current phase**: v4 stable — incremental feature work and docs maintenance
- **Library version**: `4.0.8`
- **Last updated**: 2026-05-05

## Completed Work
- v4 library shipped as the active version
- v3 archived under `tests/v3-baseline/` (read-only via deny rule)
- Repo reorganized into `release/lib/` and `release/<publisher>/`
- `CHAMFER_N` parameter for exterior edge chamfering; units = chamfer surface diagonal width (perpendicular leg = `CHAMFER_N / sqrt(2)`); default 0.6 mm
- `CHAMFER_N` cavity chamfers fixed for non-square shapes (vertical hex/oct/round) and now also chamfer the cavity opening; manifold-clean STL output
- `release/lib/bit_functions_lib.4.scad` retired (was unused by the engine)
- AGENTS.md consolidated to ~100 lines
- Version-stamping: `scripts/package-release.sh --patch` for bug fixes/internal changes, `--minor` for user-facing features. The pre-commit hook increments patch by default only when the dev lib has changed since the current full-version file; set `BIT_VERSION_BUMP=minor` for feature-release commits.
- Release packaging: `scripts/package-release.sh` writes full-version library files beside the moving dev file in `release/lib/`, updates shipped starter/example includes to the immutable filename, and smoke-compiles shipped entry files.
- Sliding lids added via `LID_TYPE = LID_SLIDING`, including configurable slide side, printable 45-degree rail/lid wedge, half-wall bearing shelf, top-open slide entry, and opening-side detent.
- Sliding lid sizing now accounts for rail shelf clearance, `2 * G_TOLERANCE` on each rail side, `G_TOLERANCE` at the stop side, and vertical tolerance above/below the panel.
- Patterned non-solid lids support `LID_FRAME_WIDTH` across cap, inset, and sliding lid types; default is wall thickness, and `0` omits the frame.
- Physical validation first slice added under `G_VALIDATE_KEYS_B`: thin walls/details, component bounds/height, component footprint overlap, and thin divider warnings.

## Active Specs
_None tracked yet._

## Known Issues
- `CHAMFER_N` top chamfer for square cavities eats into partition walls in multi-compartment grids (no per-side cap yet)
- `CHAMFER_N` for laid-down hex/oct cavities is a no-op (the floor is curved; no clean chamfer geometry)
