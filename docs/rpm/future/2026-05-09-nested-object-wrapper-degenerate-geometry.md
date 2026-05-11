# Normalize Or Reject Nested OBJECT_BOX Wrapper Data

## Context

BGSD can emit element data in a nested wrapper shape:

```scad
[ OBJECT_BOX, [
  [ NAME, "box 2" ],
  [ BOX_SIZE_XYZ, [50, 50, 20] ],
  [ BOX_FEATURE,
    [ FTR_COMPARTMENT_SIZE_XYZ, [40, 40, 15] ],
  ],
]]
```

BIT expects flat element entries:

```scad
[ OBJECT_BOX,
  [ NAME, "box 2" ],
  [ BOX_SIZE_XYZ, [50, 50, 20] ],
  [ BOX_FEATURE,
    [ FTR_COMPARTMENT_SIZE_XYZ, [40, 40, 15] ],
  ],
]
```

The nested wrapper appears to reach `MakeBox()` as the element, causing normal `__value()` lookups for `BOX_SIZE_XYZ` and `BOX_FEATURE` to miss the intended keys. The reported result is degenerate geometry.

## Next Steps

- Reproduce with the minimal BGSD-shaped case.
- Decide whether to normalize one nested wrapper level for known object entries or reject it with a BGSD-formatted diagnostic.
- Add a regression test covering the chosen behavior.
- Run at least the affected test and full `--csg-only` before release.

## Worker Result

### Summary

Normalized exactly one BGSD-style nested wrapper level for recognized `OBJECT_*` entries during `Make()` element filtering. The nested `OBJECT_BOX` repro previously compiled with no warnings but exported empty STL geometry; the new regression now exports non-empty geometry and renders successfully.

### Files Changed

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_nested_object_wrapper.scad`
- `docs/rpm/future/2026-05-09-nested-object-wrapper-degenerate-geometry.md`

### Verification Run

- Reproduced pre-fix behavior with `./tests/render_eval.sh --inline ...`: compile OK, STL export empty.
- `./tests/run_tests.sh --csg-only test_nested_object_wrapper` — PASS.
- `./tests/run_tests.sh --view-timeout 120 test_nested_object_wrapper` — PASS; wrote STL and seven PNG views.
- `./tests/run_tests.sh --csg-only` — PASS: 73 passed, 0 failed, 18 existing warning cases.

### Remaining Risks Or Follow-Ups

- Normalization is intentionally limited to one wrapper level and only for recognized `OBJECT_*` entries. Deeper malformed nesting is still treated as malformed input by existing validation/render behavior.
