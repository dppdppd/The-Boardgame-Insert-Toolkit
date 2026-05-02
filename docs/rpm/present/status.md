# BIT — Present State

## Project Status
- **Current phase**: v4 stable — incremental feature work and docs maintenance
- **Library version**: `4.0.1` (auto-stamped from commit count since `v4.0.0` tag)
- **Last updated**: 2026-05-02

## Completed Work
- v4 library shipped as the active version
- v3 archived under `tests/v3-baseline/` (read-only via deny rule)
- Repo reorganized into `release/lib/` and `release/<publisher>/`
- `CHAMFER_N` parameter for exterior edge chamfering; units = chamfer surface diagonal width (perpendicular leg = `CHAMFER_N / sqrt(2)`); default 0.5 mm
- `CHAMFER_N` cavity chamfers fixed for non-square shapes (vertical hex/oct/round) and now also chamfer the cavity opening; manifold-clean STL output
- `release/lib/bit_functions_lib.4.scad` retired (was unused by the engine)
- AGENTS.md consolidated to ~100 lines
- Auto-version-stamping: `v4.0.0` baseline tag + `scripts/hooks/pre-commit` + `scripts/install-hooks.sh`. Each commit auto-bumps the patch number; no manual version bumps.

## Active Specs
_None tracked yet._

## Known Issues
- `CHAMFER_N` top chamfer for square cavities eats into partition walls in multi-compartment grids (no per-side cap yet)
- `CHAMFER_N` for laid-down hex/oct cavities is a no-op (the floor is curved; no clean chamfer geometry)
