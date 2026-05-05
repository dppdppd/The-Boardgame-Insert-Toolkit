# The Boardgame Insert Toolkit (BIT) — Agent Instructions

## Project Overview

OpenSCAD parametric library for designing 3D-printable board game box inserts with lids.
Users define boxes via key-value data structures; the library renders them into 3D geometry.

- **Language**: OpenSCAD (declarative CSG modeling)
- **Active version**: v4 — `release/lib/boardgame_insert_toolkit_lib.4.scad`
- **Legacy version**: v3 — archived in `tests/v3-baseline/` (preserved for reference)
- **Entry point**: User `.scad` files call `Make(data)` which processes a flat data array
- **License**: CC BY-NC-SA 4.0
- **Repo**: https://github.com/dppdppd/The-Boardgame-Insert-Toolkit

## Architecture

### Data Flow
1. User defines a flat data array — globals as `[G_*, value]` pairs, then element entries (OBJECT_BOX, OBJECT_DIVIDERS, OBJECT_SPACER)
2. `Make(data)` extracts globals, filters elements, dispatches to `MakeBox()` or `MakeDividers()` based on type key
3. Each box goes through layered CSG pipeline: outer shell → feature subtractions → additions → cutouts → lid
4. Output is OpenSCAD geometry exportable as STL

### Key Modules (in boardgame_insert_toolkit_lib.4.scad)
| Module | Purpose |
|--------|---------|
| Constants/Keywords/Defaults | Parameter name constants, shape enums, internal defaults |
| Key-Value Helpers | `__index_of_key()`, `__value()` — dictionary lookup |
| Utility Modules | debug, rotate, mirror, colorize, shear |
| Data Accessors | Extract parameters, auto-size, data with defaults |
| Geometry Helpers | `Make2dShape`, `Make2DPattern`, `MakeStripedGrid` |
| Key Validation | `__ValidateTable`, `__ValidateElement`, type checks |
| `Make()` | Top-level entry, extracts globals, validates keys, dispatches per element |
| `MakeDividers()` | Card dividers with tabs and frames |
| `MakeBox()` / `MakeLayer()` | Box generation + feature processing pipeline |
| `MakeRoundedCubeAxis()` | Rounded cube utility |

The lib (~3,454 lines) has a Table of Contents in its header comment. Use `grep -n "^module"` to find current line numbers — they shift with edits.

## Rendering & Testing

Two-phase pipeline: STL export (slow, CGAL) → multi-view PNG (fast, import STL).

```bash
./tests/run_tests.sh --csg-only                    # Fast compile check (~7s total)
./tests/run_tests.sh test_box_minimal              # Single test, all 7 views
./tests/render_eval.sh tests/v4/scad/test_box_minimal.scad  # Eval render (iso + top)
```

Tests live in `tests/v4/scad/`; v3 baseline in `tests/v3-baseline/`.

> Full CLI reference, camera views, eval tool options, and test infrastructure details: [docs/guidance/RENDERING.md](docs/guidance/RENDERING.md)

## Key Paths

| Path | Purpose |
|------|---------|
| `release/lib/*.4.scad` | v4 library files (active) |
| `release/my_designs/` | User projects, starter, examples |
| `tests/v4/scad/test_*.scad` | 53 v4 test files |
| `tests/v3-baseline/` | v3 regression baseline (read-only) |
| `scripts/hooks/pre-commit` | Stamps `VERSION`; patch by default, `BIT_VERSION_BUMP=minor` for feature releases |
| `scripts/install-hooks.sh` | One-time per clone: `git config core.hooksPath scripts/hooks` |

> Full file conventions table and test template: [docs/guidance/RENDERING.md](docs/guidance/RENDERING.md)

## Visual Editor

The visual editor (BGSD — Board Game Storage Designer) has been split into its own repo:
**[github.com/dppdppd/BGSD](https://github.com/dppdppd/BGSD)**

## Code Style

- **OpenSCAD**: Constants/keys in UPPERCASE, modules in PascalCase, 2-space indent
- **Git commits**: `type(scope): message` (e.g., `feat:`, `fix:`, `docs:`)

## Key Design Decisions

- **Two-phase rendering**: STL export (slow, CGAL) then PNG views (fast, import STL) — separated for efficiency
- **Pre-commit version stamping**: the `scripts/hooks/pre-commit` hook mutates the lib and `git add`s it from inside the hook so the version stamp rides along in the commit being made. Patch is the default bump for bug fixes/internal changes; set `BIT_VERSION_BUMP=minor` for user-facing feature releases. Pre-push wouldn't work for new commits — git determines the push spec before the hook runs, so a hook-created commit wouldn't be included in the current push.

## Library Refactor Workflow

Key principles for structured library changes:
- **One logical change per cycle** — never batch multiple tasks
- **Always render BEFORE baselines** before patching, even for "trivial" changes
- **Refactors must produce identical geometry** — compare BEFORE/AFTER PNGs
- **CSG regression on all tests** after every change (`run_tests.sh --csg-only`)
- **Every new or changed test must generate renders** — run the affected test(s) without `--csg-only` so STL and all seven PNG views are written to `tests/v4/renders/`
- **Update docs every cycle** — stale plans are worse than no plan

> Historical workflow docs (ASSESS → PATCH → EVALUATE cycle) archived in `docs/archive/opencode/`.

## Git Workflow

- Branch: `master`
- Remote: `https://github.com/dppdppd/The-Boardgame-Insert-Toolkit.git`
- Push: `GIT_ASKPASS=/home/pa/tmp/git-askpass.sh git push`
- `.gitignore` ignores: `.stl`, `BIT_*.scad`, `*.test.scad`, `old/`, dotfiles (except `.github/`, `.claude/`), v2 legacy files
- **Tests directory (`tests/`) is NOT gitignored**

## Parameters

> Full parameter reference (element, feature, lid, label, divider, globals, helper functions): [docs/guidance/BIT-PARAMETERS.md](docs/guidance/BIT-PARAMETERS.md)
