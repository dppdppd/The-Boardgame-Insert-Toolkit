---
name: bit-refactor
description: Assess-patch-evaluate loop for refactoring the Boardgame Insert Toolkit OpenSCAD library
---

## What I do

Define the full assess-patch-evaluate work loop for making changes to `boardgame_insert_toolkit_lib.3.scad`. This skill is loaded at the start of every refactor session and governs the methodology.

## When to use me

Load this skill when:
- Starting a refactor work session on the BIT library
- Resuming work after a break (context may be stale)
- Uncertain about the correct workflow for a change

## The Work Loop

Every change to the library follows this exact loop. No shortcuts.

```
ASSESS -> PATCH -> EVALUATE -> UPDATE DOCS -> repeat
```

### Step 1: ASSESS (use @bit-assessor)

Invoke the bit-assessor agent. It will:
1. Read `CLEANUP_PLAN.md` to find the next pending task
2. Read the relevant section of the library source
3. Produce a **patch specification**:
   - Exact task ID from the plan
   - What to change (old code -> new code, or description of structural change)
   - Which test files to use for verification
   - Which render views are relevant
   - What to look for in the before/after comparison
   - Risk level (low/medium/high)

The assessor does NOT make changes. It only produces the spec.

### Step 2: PATCH (use @bit-patcher)

Invoke the bit-patcher agent with the patch spec from step 1. It will:
1. Render BEFORE baselines using `render_eval.sh`
2. Make the exact code change specified
3. Run a fast CSG compile check (`run_tests.sh --csg-only`)
4. If CSG fails: fix the issue, re-check, document what went wrong
5. Report what was changed and whether CSG passed

The patcher makes ONE logical change. Never batches multiple tasks.

### Step 3: EVALUATE (use @bit-evaluator)

Invoke the bit-evaluator agent. It will:
1. Render AFTER views matching the BEFORE baselines
2. Read both before and after PNGs and compare them
3. For refactors: verify geometry is IDENTICAL (no visible differences)
4. For bugfixes: verify intended change is present AND nothing else changed
5. Run broader regression if needed (2-3 key tests across feature areas)
6. Report: PASS (proceed to commit), FAIL (describe what's wrong), or WARN (needs human review)

If FAIL: the patcher is re-invoked to fix the issue. The evaluator re-runs.
If PASS: proceed to step 4.

### Step 4: UPDATE DOCS

After every successful change, update ALL of these:
1. **`CLEANUP_PLAN.md`**: Mark task done, update line numbers, add discoveries
2. **`AGENTS.md`**: If the change affects architecture, parameters, or module layout
3. **Agent/skill files**: If the workflow itself needs adjustment based on what was learned

This step is NOT optional. A stale plan is worse than no plan.

### Step 5: COMMIT

Create a git commit with:
- One logical change per commit
- Message format: `refactor: <what>` or `fix: <what>` or `cleanup: <what>`
- Never mix refactors and bugfixes in one commit

Then return to Step 1 for the next task.

## Key Project Paths

| Path | Purpose |
|------|---------|
| `boardgame_insert_toolkit_lib.3.scad` | The library (THE target) |
| `bit_functions_lib.3.scad` | Helper functions library |
| `CLEANUP_PLAN.md` | Phased refactor plan with task status |
| `AGENTS.md` | Project reference, architecture, render commands |
| `tests/run_tests.sh` | Full test runner (CSG + STL + 7-view PNG) |
| `tests/render_eval.sh` | Targeted evaluation tool |
| `tests/test_*.scad` | 53+ test files |
| `tests/renders/` | Generated PNGs |
| `tests/renders/eval/` | Ad-hoc evaluation renders |

## Render Commands Quick Reference

```bash
# Fast compile check (all tests, ~15s)
./tests/run_tests.sh --csg-only

# Single test with all 7 views
./tests/run_tests.sh test_box_minimal

# Targeted evaluation with before/after naming
./tests/render_eval.sh tests/test_box_minimal.scad --views iso,top --name before
./tests/render_eval.sh tests/test_box_minimal.scad --views iso,top --name after

# Cross-section for internal geometry
./tests/render_eval.sh tests/test_box_minimal.scad --cross-section z,7

# Inline test (no file needed)
./tests/render_eval.sh --inline 'include <boardgame_insert_toolkit_lib.3.scad>;
  data=[["t",[[BOX_SIZE_XYZ,[50,50,20]],
    [BOX_COMPONENT,[[CMP_COMPARTMENT_SIZE_XYZ,[46,46,18]]]]]]];
  MakeAll();'
```

## Evaluation Criteria by Change Type

| Change Type | Expected Outcome | Views to Check |
|------------|-----------------|----------------|
| Dead code removal | Identical geometry | iso (any test) |
| Extract to file scope | Identical geometry | iso, top (pattern/label tests) |
| Parameterize module | Identical geometry | iso, front (relevant feature tests) |
| Bug fix | Specific change only | views showing the bug |
| Magic number rename | Identical geometry | iso (any test) |
| Consolidate duplicates | Identical geometry | iso, top (tests using both variants) |

## Anti-Patterns (DO NOT)

- Do NOT batch multiple tasks into one change
- Do NOT skip the BEFORE render baseline
- Do NOT skip updating CLEANUP_PLAN.md
- Do NOT mix refactors with bugfixes in one commit
- Do NOT assume a change is safe without rendering
- Do NOT update line numbers in the plan without verifying them
- Do NOT skip CSG regression even for "trivial" changes
