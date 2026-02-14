# Cleanup Plan — The Boardgame Insert Toolkit

> **Rule**: Every work loop must end with "Update this plan" before committing.  
> Stale plans are worse than no plan.

---

## Principles

1. **No geometry changes during refactor phases.** Every refactor step must produce identical STL output, verified by before/after renders + CSG regression.
2. **One logical change per commit.** Small, reviewable, reversible.
3. **Bugfixes are separate from refactors.** Bugs go in Phase 0 or a dedicated bugfix phase, never mixed into refactor commits.
4. **Update this plan after every work session.** Mark what's done, what changed, what was discovered.

---

## Work Loop (every change)

Driven by three agents in `.opencode/agents/` and one skill in `.opencode/skills/bit-refactor/`.
Load the `bit-refactor` skill at the start of each session for full methodology.

```
ASSESS:   @bit-assessor  — read plan, find next task, produce patch spec
PATCH:    @bit-patcher   — render BEFORE, apply change, run CSG, update docs
EVALUATE: @bit-evaluator — render AFTER, compare, run regression, report verdict
COMMIT:   if PASS → git commit → back to ASSESS
          if FAIL → @bit-patcher fixes → @bit-evaluator re-evaluates
```

Expanded steps:
1. `@bit-assessor` reads this plan, finds next `[ ] pending` task, reads source, outputs patch spec
2. `@bit-patcher` renders BEFORE baselines, applies the exact change, runs `run_tests.sh --csg-only`
3. `@bit-evaluator` renders AFTER views, compares with BEFORE, runs 2-3 regression tests, reports PASS/FAIL/WARN
4. If PASS: commit with `refactor:` / `fix:` / `cleanup:` prefix
5. **UPDATE THIS PLAN** — mark task done, update line numbers, add discoveries, adjust future tasks
6. Update `AGENTS.md` if architecture changed
7. Update agent/skill files if workflow gaps were found
8. Repeat

---

## Phase 0: Bugs & Dead Code (pre-refactor cleanup)

Minimal-risk changes. Fix known bugs, remove dead code. Each is independent.

### 0.1 Fix divider_top bug
- **File**: `boardgame_insert_toolkit_lib.3.scad` line 547
- **Bug**: `divider_top = __div_frame_bottom(div)` should be `__div_frame_top(div)`
- **Impact**: Changes geometry for dividers that use `DIV_FRAME_TOP` != `DIV_FRAME_BOTTOM`
- **Verify**: Basic divider tests identical (defaults equal); asymmetric inline test (TOP=5, BOTTOM=15) shows fix — 1.22% pixel diff in iso view
- **Status**: [x] done

### 0.2 Fix duplicate `__div_tab_size` definition
- **Lines**: 384 and 397 — identical definition, removed line 397
- **Impact**: None (identical)
- **Status**: [x] done

### 0.3 Fix Make2dShape typo `n1 == 6 && n1 == 6`
- **Lines**: 1549 (MakeBox), 3649 (MakeHexBox) — fixed to `n1 == 6 && n2 == 6`
- **Impact**: Only affects cases where n1=6 but n2!=6 (rare but incorrect dispatch)
- **Verify**: CSG-only regression — 53/53 pass
- **Status**: [x] done

### 0.4 Remove dead code
Remove in one commit per category:

**Dead functions/modules (never called):**
- [x] `MakeRoundedCubeAll` — removed
- [x] `MakeCorners(mod)` — removed
- [x] `__ColorComponent()` in MakeBox and MakeHexBox — removed
- [x] `__partition_height_scale(D)` — removed (referenced undefined symbols)
- [x] `__component_position_max(D)` — removed
- [x] `__compartment_smallest_dimension()` — removed
- [x] `__component_is_round()` — removed

**Dead variables (computed, never read):**
- [x] `m_component_has_exactly_one_cutout` — removed
- [x] `m_ignore_position` — removed
- [x] `m_box_label` — removed
- [x] `m_tab_width_x` / `m_tab_width_y` — removed
- [x] `m_lid_label_depth` — removed
- [x] `m_tab_corner_gap` (global) — removed
- [x] `m_wall_underside_lid_storage_depth` (global) — removed

### 0.5 Remove debug echo lines in MakeHexBox
- **Lines**: 3627-3628 (Make2DPattern), 3828 (MakeLidLabelFrame) — commented out to match MakeBox
- **Impact**: No geometry change, just removes console noise
- **Status**: [x] done

### 0.6 Fix raw string `"wall_thickness"` → use constant
- **Lines**: 645, 2727 — `__value(box, "wall_thickness", ...)` uses raw string
- **Investigated**: This is an undocumented per-box wall thickness override. The raw string is the user-facing key name. Should define `BOX_WALL_THICKNESS = "wall_thickness"` constant and use it, but this is low priority and can wait for Phase 5 (magic numbers).
- **Status**: [x] deferred to Phase 5

---

## Phase 1: Extract Shared Geometry Helpers

Move code that is **100% identical** between MakeBox and MakeHexBox to file-scope modules/functions. No logic changes — pure extraction.

### 1.1 Extract polygon helpers to file scope
**What**: `Tri`, `Quad`, `Pent`, `Hex`, `Sept`, `Oct`, `AddPoint`, `AddOrderIndex`, `Make2dShape`
**Done**: Extracted to file scope (after Shear, before MakeAll). Removed both MakeBox and MakeHexBox copies.
**Result**: -191 lines net. 53/53 CSG pass. 0% pixel diff on lid pattern + n1n2 pattern tests.
- [x] Extract polygon modules (Tri through Oct)
- [x] Extract `AddPoint`, `AddOrderIndex`, `Make2dShape`
- [x] Remove duplicates from MakeBox and MakeHexBox
- [x] Verify — 0% pixel diff, identical STL sizes

### 1.2 Extract pattern generation to file scope
**What**: `Make2DPattern`, `MakeStripedGrid`
**Done**: Extracted to file scope (after Make2dShape, before MakeAll). Added 5 explicit parameters to `Make2DPattern` (pattern_angle, pattern_col_offset, pattern_row_offset, pattern_n1, pattern_n2). Changed `MakeStripedGrid` default thickness from `m_lid_thickness` to `1` (all callsites pass explicitly). Removed both MakeBox and MakeHexBox copies.
**Result**: -69 lines net (4582→4513). 53/53 CSG pass. 0% pixel diff on lid pattern, stripes, and n1n2 pattern tests.
- [x] Add parameters to `Make2DPattern` for pattern config
- [x] Add parameters to `MakeStripedGrid` for stripe config
- [x] Extract to file scope
- [x] Remove duplicates
- [x] Verify — 0% pixel diff across 6 comparisons

### 1.3 Consolidate polygon helpers into single parameterized module
**What**: Replace 6 hardcoded polygon modules (Tri-Oct) with one generic approach
**Done**: Removed Tri/Quad/Pent/Hex/Sept/Oct and the if/else dispatch in Make2dShape. Renamed AddPoint→__ngon_points, AddOrderIndex→__ngon_indices. Make2dShape now always uses the generic path (outer + inner point rings). Verified via symmetric-difference STL test that hand-unrolled and generic produce identical geometry (empty difference).
**Result**: -178 lines net (4513→4335). 53/53 CSG pass. 0% pixel diff on pattern and n1n2 tests.
- [x] Verify hand-unrolled and generic approaches produce identical geometry
- [x] Simplify Make2dShape to always use generic __ngon_points/__ngon_indices
- [x] Remove Tri/Quad/Pent/Hex/Sept/Oct modules
- [x] Verify — 0% pixel diff across 4 comparisons

---

## Phase 2: Extract Shared Label & Iteration Code

**STATUS: BLOCKED** — All target modules depend on `__` accessor functions scoped inside MakeBox/MakeHexBox. 6 of 39 accessors differ between box types (mostly `k_z` vs `k_hex_z`). Cannot extract to file scope without first unifying the accessor layer (Phase 4). Phases 2 and 3 as written are deferred.

**2.0 (DONE)**: Introduced `m_box_height_index` variable (`k_z` in MakeBox, `k_hex_z` in MakeHexBox) to eliminate the most common diff category. Replaced 19 `m_box_size[k_z]` refs in MakeBox and 20 `m_box_size[k_hex_z]` refs in MakeHexBox.

**4.0 (DONE)**: Unified all remaining differing accessor functions via precomputed dimension arrays:
- Added `m_lid_size_ext`, `m_lid_size_int`, `m_notch_length_base` arrays in both MakeBox and MakeHexBox
- `__lid_external_size`, `__lid_internal_size`, `__notch_length` now all use simple array lookups
- Result: **35/35 MakeLayer functions** and **4/4 top-level accessors** are now identical between MakeBox and MakeHexBox

These are **100% identical** between MakeBox and MakeHexBox but may reference parent-scope variables.

### 2.1 Extract label helpers
**Identical modules**:
- `Make2dLidLabel` (1673-1692 / 3773-3792)
- `MakeLidLabel` (1694-1707 / 3794-3807)
- `MakeAllLidLabels` (1643-1654 / 3743-3754)
- `MakeDetachedLidLabels` (1824-1832 / 3926-3934)
- `MakeAllLidLabelFrames` (1776-1787 / 3876-3887)
- `MakeLidLabelFrame` (1789-1822 / 3889-3924)
- `Helper_MakeLabel` (2448-2485 / 4541-4578)
- `MakeLabel` (2487-2537 / 4580-4630)

**Near-identical** (differ by `k_z` vs `k_hex_z`):
- `Helper_MakeBoxLabel` (1709-1734 / 3809-3834) — parameterize height
- `MakeBoxLabel` (1736-1772 / 3836-3872) — parameterize height
- `MakeAllBoxLabels` (1656-1671 / 3756-3771)

**Approach**: Extract identical ones first, then parameterize near-identical ones with a `box_height` parameter.
- [ ] Extract identical label modules to file scope
- [ ] Parameterize and extract near-identical label modules
- [ ] Remove duplicates
- [ ] Verify: render label tests + lid label tests

### 2.2 Extract iteration helpers
**Identical modules**:
- `ForEachPartition(D)` (2016-2033 / 4109-4126)
- `ForEachCompartment(D)` (2035-2050 / 4128-4143)
- `InEachCompartment()` (2052-2069 / 4145-4162)
- `LabelEachCompartment()` (2071-2100 / 4164-4193)
- `MakeAllBoxSideCutouts()` (1332-1359 / 3432-3459)
- `MakeAllBoxCornerCutouts()` (1361-1369 / 3461-3469)

**Problem**: These use parent-scope variables (`m_compartment_*`, component params)
**Solution**: Pass required values as parameters
- [ ] Identify all parent-scope references in each module
- [ ] Add explicit parameters
- [ ] Extract to file scope
- [ ] Remove duplicates
- [ ] Verify: render cutout + positioning tests

### 2.3 Extract fillet, partition, and margin modules
**Identical**:
- `AddFillets()` (2332-2368 / 4425-4461)
- `MakePartitions()` (2539-2557 / 4632-4650)
- `MakeMargin(side)` (2559-2572 / 4652-4665)
- `MakePartition(axis)` (2574-2584 / 4667-4677)
- `MakeVerticalShape(h, x, r)` (2370-2385 / 4463-4478)
- `MakeCompartmentShape()` (2387-2446 / 4480-4539) — differs by `k_z`/`k_hex_z` only

**Approach**: Extract identical, parameterize height for near-identical
- [ ] Extract and parameterize
- [ ] Verify: render shape tests + fillet test

---

## Phase 3: Extract Shared Cutout & Structural Code

Larger, more complex modules. Higher risk.

### 3.1 Extract cutout modules
**Near-identical** (differ by `k_z` vs `k_hex_z`):
- `MakeSideCutouts(side, margin)` (2103-2237 / 4196-4330) — 134 lines each
- `MakeCornerCutouts(corner)` (2239-2328 / 4332-4421) — 89 lines each

**Approach**: Add `box_height` parameter, extract to file scope
- [ ] Parameterize MakeSideCutouts
- [ ] Parameterize MakeCornerCutouts
- [ ] Extract
- [ ] Verify: render all cutout tests

### 3.2 Extract InnerLayer
**Near-identical** (differ by `k_z`/`k_hex_z`, hex omits some side-cutout checks):
- `InnerLayer()` (1204-1330 / 3311-3430) — 126/119 lines

**Higher risk**: Complex CSG pipeline (additions, subtractions, final subtractions)
**Approach**: Parameterize the differences, extract
- [ ] Map all differences between MakeBox and MakeHexBox versions
- [ ] Create parameterized version
- [ ] Verify: render multiple integration tests

### 3.3 Extract MakeLayer component accessor functions
**Identical**: ~30 accessor functions (800-894 / 2928-3022), ~94 lines
**Problem**: These read from `component` which is a MakeLayer parameter
**Solution**: These are already functions — can be extracted if `component` is passed as parameter
- [ ] Refactor accessors to take `component` parameter
- [ ] Extract to file scope
- [ ] Verify

---

## Phase 4: Reduce MakeBox/MakeHexBox Duplication (Structural)

### 4.0 Unify accessor functions — DONE
Introduced `m_box_height_index`, `m_lid_size_ext`, `m_lid_size_int`, `m_notch_length_base` precomputed arrays. All 35 MakeLayer functions and all 4 top-level accessors are now identical between MakeBox and MakeHexBox.

### 4.1 MakeLayer dedup assessment — DONE (deferred)
After accessor unification, diffed MakeLayer copies:
- **1,690 lines** (MakeBox) vs **1,585 lines** (MakeHexBox)
- **319 lines** differ (whitespace-insensitive)
- **73 diff hunks** concentrated in two areas:
  1. **Shell/lid structure** (~lines 1-500): `cube()` vs `cylinder($fn=6)`, lid base/cap/edge/notch modules are geometrically different, hex has `m_x_offset` translate and `m_is_lid_holder` layer
  2. **Outer assembly** (~lines 1500-1690): stackable features, final geometry wrapping differ
- **Middle section** (~lines 500-1500): labels, cutouts, iteration, fillets, partitions, compartments — largely identical but cannot be extracted to file scope due to OpenSCAD scoping (closures over ~40 parent-scope variables)

**Conclusion**: Remaining MakeLayer differences are genuine geometric divergence between rectangular and hexagonal box types. Further dedup requires architectural changes (shape abstraction layer) beyond safe mechanical refactoring. This is the natural stopping point for Phases 2-4.

### Future: shape abstraction (out of scope)
Would require a `MakeShell(type)`, `MakeLidBase(type)` abstraction that dispatches cube vs cylinder geometry. High risk, significant redesign, deferred indefinitely.

**Decision point**: Is a shared `MakeBoxBase(shape_type)` worth the complexity?
- [ ] Evaluate after Phase 3 extraction results
- [ ] Document decision here

---

## Phase 5: Magic Numbers → Named Constants

### 5.1 Extract magic numbers to named constants — DONE
Added 14 named constants to the constants section and replaced 39 occurrences across the file.

| Constant | Value | Replacements |
|----------|-------|-------------|
| `DEFAULT_INSET_LID_HEIGHT` | 2.0 | 2 |
| `DEFAULT_CAP_LID_HEIGHT` | 4.0 | 2 |
| `DEFAULT_PEDESTAL_BASE_FRACTION` | 0.4 | 2 |
| `DEFAULT_MAX_LABEL_WIDTH` | 100 | 4 |
| `DEFAULT_STRIPE_ANGLE` | 45 | 2 |
| `DEFAULT_MAX_CUTOUT_CORNER_RADIUS` | 3 | 2 |
| `DEFAULT_CORNER_CUTOUT_INSET_FRACTION` | 1/4 | 2 |
| `DEFAULT_DETENT_SPHERE_RADIUS` | 1 | 2 |
| `LID_TAB_MODIFIER_SCALE` | 10 | 2 |
| `LABEL_FRAME_HULL_EXTENT` | 200 | 8 |
| `DEFAULT_DIV_TAB_RADIUS` | 4 | 1 |
| `DEFAULT_TAB_TEXT_WIDTH_FRACTION` | 0.8 | 1 |
| `MIN_CORNER_RADIUS` | 0.001 | 4 |
| `HULL_EPSILON` | 0.01 | 7 |

**Not replaced**: `m_epsilon = 0.001` (different semantics — tolerance epsilon, not hull).
**Result**: +17 lines (constants block). 53/53 CSG pass. 0% pixel diff on 5 comparisons.
- [x] Add constants to constants section
- [x] Replace all occurrences
- [x] CSG regression

---

## Phase 6: Code Organization & Documentation

### 6.1 Add section headers and TOC — DONE
- [x] Added table of contents comment block at top of file with line numbers
- [x] Added 9 `// ====` section dividers at major boundaries
- [x] Removed 4 old `////` noise dividers
- [x] Added doc comments to MakeAll, MakeBox, MakeHexBox, MakeLayer (both copies)
- [x] Documented the 7 MakeLayer pipeline stages in comment block
- [x] 53/53 CSG pass

### 6.3 Evaluate file splitting — DEFERRED
At 4,421 lines the file is large but manageable as a single file. The TOC and section headers make navigation tractable. Splitting would require careful `include` ordering due to OpenSCAD's scoping model and would break existing user includes. Not recommended at this time.

---

## Discoveries Log

Record anything learned during the work that affects the plan. **Update after every session.**

| Date | Discovery | Impact |
|------|-----------|--------|
| (pre-plan) | `divider_top` bug at line 547 | Phase 0.1 bugfix |
| (pre-plan) | `Make2dShape` typo `n1 == 6 && n1 == 6` | Phase 0.3 bugfix |
| (pre-plan) | `__div_tab_size` defined twice (384, 397) | Phase 0.2 cleanup |
| (pre-plan) | `ContainWithinBox()` exists but is effectively disabled | Note for Phase 3 |
| (pre-plan) | `"wall_thickness"` uses raw string, no constant | Phase 0.6 investigation |
| (pre-plan) | MakeHexBox `MakeSpacer()` uses cube, not hex cylinder — possible bug | Investigate in Phase 0 |
| (pre-plan) | ~1800 of MakeHexBox's 2019 lines are duplicated from MakeBox | Core motivation for Phases 1-4 |
| 2026-02-14 | Phase 0.1 fixed. Existing divider tests use equal top/bottom defaults so show no diff. Need asymmetric inline test to verify bugfixes like this. | Methodology note |

---

## Progress Summary

| Phase | Description | Tasks | Done | Status |
|-------|-------------|-------|------|--------|
| 0 | Bugs & Dead Code | 6 groups | 6 | Done |
| 1 | Extract Shared Geometry | 3 groups | 1 | In progress |
| 2 | Extract Labels & Iteration | 3 groups | 0 | Not started |
| 3 | Extract Cutouts & Structure | 3 groups | 0 | Not started |
| 4 | Reduce Box/HexBox Duplication | 3 groups | 0 | Not started |
| 5 | Magic Numbers → Constants | 1 group | 0 | Not started |
| 6 | Organization & Documentation | 3 groups | 0 | Not started |

---

## Line Number Index (update after each phase)

Key reference points for navigation. **Must be updated after any change that shifts line numbers.**

| Item | Line(s) | Last verified |
|------|---------|---------------|
| Constants/Keywords + defaults | 1-227 | Phase 5.1 |
| Key-value helpers | 213-215 | pre-plan |
| Globals | 219-295 | pre-plan |
| Utility modules (debug..Shear) | 307-470 | Phase 1.3 |
| __ngon_points, __ngon_indices | 474-479 | Phase 1.3 |
| Make2dShape (file scope) | 481-489 | Phase 1.3 |
| Make2DPattern (file scope) | 491-525 | Phase 1.3 |
| MakeStripedGrid (file scope) | 527-553 | Phase 1.3 |
| MakeAll | 556-611 | Phase 2.0 |
| MakeDividers | 613-721 | Phase 2.0 |
| MakeBox start | 723 | Phase 2.0 |
| m_box_height_index = k_z | 756 | Phase 2.0 |
| MakeHexBox start | 2545 | Phase 2.0 |
| m_box_height_index = k_hex_z | 2577 | Phase 2.0 |
| MakeRoundedCubeAxis | 4284-4336 | Phase 2.0 |
| **Total lines** | **4421** | Phase 6.1 |
