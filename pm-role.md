# PM Role — The Boardgame Insert Toolkit (BIT)

Created: 2026-03-31
Last updated: 2026-03-31

## Project Summary
OpenSCAD parametric library for designing 3D-printable board game box inserts with lids. Active version is v4 (~3,454 lines). Users define boxes via key-value data structures; `Make(data)` renders them into 3D geometry. Project started Feb 2019; visual editor (BGSD) has been split to a separate repo.

## Documentation Landscape
| Location | Files | Role |
|----------|-------|------|
| `CLAUDE.md` | 1 line | Pointer to AGENTS.md |
| `AGENTS.md` | 100 lines | Core agent instructions — architecture, key paths, code style, workflow |
| `README.md` | 696 lines | User-facing: setup, examples, migration guide, contributing |
| `docs/guidance/RENDERING.md` | 116 lines | CLI reference, camera views, test infra, file conventions, test template |
| `docs/guidance/BIT-PARAMETERS.md` | 30 lines | Parameter name reference for all data array levels |
| `docs/archive/` | 8 files | Archived pre-edit versions of AGENTS.md (v01, v02), README.md, .opencode/ docs |
| `.claude/settings.json` | 1 file | Denies edits to `tests/v3-baseline/` |

## Current Priorities
- **LOW**: Expand `.claude/settings.json` hooks — currently only denies v3-baseline edits; could add commit message format, CSG regression pre-commit
- **LOW**: Update lib file's internal TOC (line numbers in comment header are stale) — this is a code change, not a doc change

## Open Questions
- Is CI planned? The false claim was removed from AGENTS.md but no `.github/` directory exists.

## Audit History

### 2026-03-31 — audit
- Scanned: 9 docs | VALID: 2 | STALE: 16 | CONTRADICTORY: 3 | MISSING: 5
- LLM-effectiveness: Tier placement WARN (AGENTS.md 233 lines), structure GOOD (80%), duplication WARN (3 places), actionability GOOD, hooks MISSING
- Key findings: Repo reorganization to `release/` broke most path references in AGENTS.md and README.md. `.opencode/` docs entirely stale (target v3, wrong paths, missing CLEANUP_PLAN.md). README entry point and examples contradict v4 format.

### 2026-03-31 — implement
- Fixes applied: 17 | Remaining: 0
- Key changes: Updated all stale paths/counts in AGENTS.md and README.md for `release/` reorg. Rewrote all README examples from v3 to v4 format. Archived `.opencode/` (4 files). Restored `bit_functions_lib.4.scad` to `release/lib/`. Created `.claude/settings.json`. Removed false CI claim. Fixed `.gitignore` to exclude `.claude/` instead of `.opencode/`.

### 2026-03-31 — consolidate
- Extracted: 2 docs | Removed: 2 sections | Deleted: 1 stale skill
- AGENTS.md: 222 lines (before) → 100 lines (after)
- Key changes: Extracted rendering/testing detail → `docs/guidance/RENDERING.md` (116 lines). Extracted parameter reference → `docs/guidance/BIT-PARAMETERS.md` (30 lines). Removed staleness-prone line index and duplicative version history. Deleted stale `.claude/commands/screenshot.md` (references `bit-gui/` which was split to BGSD repo).

## PM Notes
- 2026-03-31: The `release/` directory reorganization (commits `b7b2528`, `2431bc0`) moved lib and design files but docs were not updated. This is the root cause of most staleness.
- 2026-03-31: `.opencode/` docs were written for the v3→v4 refactor (completed ~Feb 2026). The methodology is sound but all paths and targets are outdated. Safe to archive.
- 2026-03-31: ~114MB of stale temp files in `/tmp` from prior sessions.

## Sessions Reviewed
