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
**Current**: Duplicated identically inside MakeBox (1375-1569) and MakeHexBox (3475-3669)
**Target**: One copy at file scope (after utility modules, before MakeAll)
**Risk**: Low — these are pure geometry, no closures over parent scope
**Verify**: CSG regression on all 53 tests + render `test_lid_pattern_basic`
- [ ] Extract polygon modules (Tri through Oct)
- [ ] Extract `AddPoint`, `AddOrderIndex`, `Make2dShape`
- [ ] Remove duplicates from MakeBox and MakeHexBox
- [ ] Verify

### 1.2 Extract pattern generation to file scope
**What**: `Make2DPattern`, `MakeStripedGrid`
**Current**: Duplicated inside MakeBox (1571-1632) and MakeHexBox (3671-3732)
**Problem**: These reference `m_lid_pattern_*` variables from parent scope
**Solution**: Add parameters for all referenced variables
**Verify**: Render `test_lid_pattern_basic`, `test_label_lid`
- [ ] Add parameters to `Make2DPattern` for pattern config
- [ ] Add parameters to `MakeStripedGrid` for stripe config
- [ ] Extract to file scope
- [ ] Remove duplicates
- [ ] Verify

### 1.3 Consolidate polygon helpers into single parameterized module
**What**: Replace 6 hardcoded polygon modules (Tri-Oct) with one `NGon(n, R, t)` module
**Current**: Each is a hand-unrolled version of the same formula
**Already exists**: `AddPoint`/`AddOrderIndex` do this generically but are only used as fallback
**Risk**: Medium — must verify all polygon outputs match exactly
**Verify**: Render every lid pattern test, compare iso+top views
- [ ] Write `NGon(n, R, t)` using the existing `AddPoint`/`AddOrderIndex` pattern
- [ ] Update `Make2dShape` to use `NGon` instead of dispatching to Tri/Quad/etc
- [ ] Remove individual Tri/Quad/Pent/Hex/Sept/Oct modules
- [ ] Verify all pattern tests

---

## Phase 2: Extract Shared Label & Iteration Code

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

After extracting shared code, MakeBox and MakeHexBox should be much smaller. This phase tackles the remaining structural differences.

### 4.1 Extract MakeLid
**Significant differences**: Hex uses cylinder clipping, hex lid bases
**Approach**: Create a shared `MakeLid` that takes a `shape_type` parameter and dispatches to cube vs cylinder geometry
- [ ] Design the interface
- [ ] Implement
- [ ] Verify: render all lid tests for both box types

### 4.2 Simplify MakeLayer dispatch
After extracting accessors, iteration, and inner layers, MakeLayer should be much simpler.
- [ ] Review remaining MakeLayer code
- [ ] Identify further extraction opportunities
- [ ] Implement
- [ ] Verify

### 4.3 Assess MakeBox/MakeHexBox merge feasibility
At this point, evaluate whether MakeBox and MakeHexBox can share a common base.
**Genuinely hex-specific code** (~220 lines):
- Shell shape (cube vs cylinder)
- Lid bases (cube vs cylinder)
- Lid holder (hex-specific)
- Corner notches (4 mirrors vs 6 rotations)
- Lid tabs (4 sides vs 6 rotations)
- Detents (4 corners vs 6 sides)
- Size/dimension functions

**Decision point**: Is a shared `MakeBoxBase(shape_type)` worth the complexity?
- [ ] Evaluate after Phase 3 extraction results
- [ ] Document decision here

---

## Phase 5: Magic Numbers → Named Constants

### 5.1 Extract magic numbers to named constants
Add to the constants section (lines 1-210):

| Value | Context | Proposed Name |
|-------|---------|---------------|
| `4` | Divider corner radius (578, 584, 598) | `k_divider_corner_radius` |
| `0.8` | Tab text width fraction (604) | `k_tab_text_width_fraction` |
| `2.0` / `4.0` | Default lid heights (658, 2780) | `k_default_inset_lid_height` / `k_default_cap_lid_height` |
| `0.01` | Hull epsilon (1109, 3235) | `k_hull_epsilon` |
| `0.4` | Pedestal base fraction (1241, 3348) | `k_pedestal_base_fraction` |
| `100` | Max label auto-width (1700, 3800) | `k_max_label_auto_width` |
| `200` | Label frame hull offset (1806-1818) | `k_label_frame_hull_offset` |
| `45` | Stripe grid angle (1898, 4000) | `k_stripe_angle` |
| `3` | Cutout corner radius (2117) | `k_cutout_corner_radius` |
| `1/4` | Corner cutout inset fraction (2247, 4340) | `k_corner_cutout_inset_fraction` |
| `1.0` | Detent sphere radius (2684-2685) | `k_detent_sphere_radius` |
| `2` | Detents per set (2690) | `k_num_detents` |
| `10` | Lid tab modifier multiplier (2625, 4706) | `k_lid_tab_mod_multiplier` |
| `.001` | Min corner radius (4785-4788) | `k_min_corner_radius` |

- [ ] Add constants to constants section
- [ ] Replace all occurrences
- [ ] CSG regression
- **Note**: Line numbers will shift after earlier phases. Update before starting.

---

## Phase 6: Code Organization & Documentation

### 6.1 Add section headers and TOC
- [ ] Add clear `// ====` section dividers
- [ ] Add a table of contents comment block at the top
- [ ] Group related code into logical sections

### 6.2 Add function/module documentation
- [ ] Document non-obvious parameters
- [ ] Document the CSG pipeline stages in MakeLayer
- [ ] Document the lid assembly pipeline

### 6.3 Evaluate file splitting
**Decision point**: After all refactoring, is the file small enough to manage as one file?
If not, split into:
- `bit_constants.3.scad` — constants, enums, keywords
- `bit_accessors.3.scad` — data accessor functions
- `bit_geometry.3.scad` — shared geometry modules (polygons, patterns, labels, cutouts)
- `bit_box.3.scad` — MakeBox
- `bit_hexbox.3.scad` — MakeHexBox
- `bit_dividers.3.scad` — MakeDividers
- `boardgame_insert_toolkit_lib.3.scad` — thin wrapper that `include`s all of the above

- [ ] Evaluate post-refactor
- [ ] If splitting: design include order, test with all 53 tests
- [ ] Update all user-facing files that include the lib

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
| 1 | Extract Shared Geometry | 3 groups | 0 | Not started |
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
| Constants/Keywords | 1-210 | pre-plan |
| Key-value helpers | 213-215 | pre-plan |
| Globals | 219-295 | pre-plan |
| Utility modules | 309-470 | pre-plan |
| Data accessors | 361-445 | pre-plan |
| MakeAll | 472-527 | pre-plan |
| MakeDividers | 529-620 | pre-plan |
| MakeBox start | 639 | pre-plan |
| MakeBox::MakeLayer | 784-1044 | pre-plan |
| MakeBox::polygons | 1375-1569 | pre-plan |
| MakeBox::patterns | 1571-1632 | pre-plan |
| MakeBox::labels | 1643-1822 | pre-plan |
| MakeBox::MakeLid | 1834-2014 | pre-plan |
| MakeBox::iteration | 2016-2100 | pre-plan |
| MakeBox::cutouts | 2103-2328 | pre-plan |
| MakeBox::shapes | 2332-2446 | pre-plan |
| MakeBox::compartment labels | 2448-2537 | pre-plan |
| MakeBox::partitions | 2539-2584 | pre-plan |
| MakeBox::lid structure | 2586-2755 | pre-plan |
| MakeBox end | 2758 | pre-plan |
| MakeHexBox start | 2761 | pre-plan |
| MakeHexBox end | 4780 | pre-plan |
| MakeRoundedCubeAxis | 4782-4834 | pre-plan |
| MakeRoundedCubeAll (DEAD) | 4837-4878 | pre-plan |
