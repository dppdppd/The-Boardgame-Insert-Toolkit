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
