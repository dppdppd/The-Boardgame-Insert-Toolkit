# Generated Design Validation

Use this workflow for arbitrary user `.scad` files generated with BIT. Library regression tests still use `tests/run_tests.sh`.

## Fast Compile Check

```bash
scripts/validate-design.sh path/to/design.scad
```

This writes a CSG compile artifact and log under `tests/v4/renders/generated/` by default. It fails on OpenSCAD errors and reports `BIT:` messages and warnings.

## Compile And Render

```bash
scripts/validate-design.sh --render path/to/design.scad
```

This additionally exports STL and renders the default `iso,top` PNG views. OpenSCAD warnings from the STL export or render phases are printed after rendering and also remain in the log.

Useful options:

```bash
scripts/validate-design.sh --render --views iso,top,front path/to/design.scad
scripts/validate-design.sh --outdir /tmp/bit-check --name card-button-draft path/to/design.scad
scripts/validate-design.sh --csg-timeout 90 --stl-timeout 900 path/to/design.scad
```

## Interpreting Results

- OpenSCAD `ERROR` lines mean the file is not ready.
- `WARNING` lines are OpenSCAD warnings. They may indicate manifold or geometry repair risks even when OpenSCAD exits successfully.
- `BIT:` lines are validation messages from BIT. Treat physical validation messages as design risks even when OpenSCAD exits successfully.
- Empty CSG or STL output means the design did not produce usable geometry.
- A passing compile does not prove physical fit. Compare the design against the measurement checklist.

## Repair Checklist

- Unknown key: check `docs/guidance/BIT-PARAMETERS.md`.
- Wrong include: user designs should include the newest full-version release library.
- Feature outside box: increase exterior `BOX_SIZE_XYZ`, reduce compartment count, or fix `POSITION_XY`.
- Tight component fit: increase `FTR_COMPARTMENT_SIZE_XYZ`.
- Lid height conflict: account for the selected lid type in the box height budget.
- Slow render: first run compile only, then render a simpler view set.
