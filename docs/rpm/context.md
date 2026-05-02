---
name: rpm-context
description: Project-local rpm context for The Boardgame Insert Toolkit (BIT)
type: project
---

# BIT — rpm Context

Injected at session start. Keep under 30 lines.

## Project Summary
OpenSCAD parametric library for designing 3D-printable board game box inserts.
Users define boxes via flat key-value data arrays; `Make(data)` renders boxes,
dividers, and spacers via a layered CSG pipeline. Solo maintainer. Active version
is v4 (`release/lib/boardgame_insert_toolkit_lib.4.scad`, ~3,454 lines); v3 is
preserved read-only in `tests/v3-baseline/`. License: CC BY-NC-SA 4.0.

## Key Files
| What | Where |
|------|-------|
| Project instructions | `AGENTS.md` (CLAUDE.md just points here) |
| Active library | `release/lib/boardgame_insert_toolkit_lib.4.scad` |
| User designs | `release/my_designs/`, `release/<publisher>/` |
| Test runner | `tests/run_tests.sh` |
| v4 tests | `tests/v4/scad/` |
| v3 baseline (read-only) | `tests/v3-baseline/` |
| Parameter reference | `docs/guidance/BIT-PARAMETERS.md` |
| Render pipeline docs | `docs/guidance/RENDERING.md` |
| PM workflow notes | `pm-role.md` |

## Focus Areas for Review
- Backwards compatibility — user designs depend on stable parameter names
- v3-baseline must remain untouched (deny rule in `.claude/settings.json`)
- Render-pipeline correctness — STL export → multi-view PNG
- Documentation accuracy — README/AGENTS reference paths that drift

## Prior Findings
See `docs/rpm/past/log.md` Audit History.
