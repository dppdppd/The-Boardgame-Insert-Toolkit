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
