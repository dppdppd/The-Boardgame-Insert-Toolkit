# Implement SVG Feature Cavity Geometry

## Description

Render SVG feature shapes as vertical custom cavities using the existing feature subtraction/add-back pipeline. The imported 2D outline should scale by real-world width, preserve aspect ratio, expand by clearance in millimeters, center in the compartment, and extrude to the feature height.

## Scope

- Add an SVG branch to `MakeCompartmentShape()`.
- Implement helper accessors for SVG file path, target width, and clearance.
- Scale the imported SVG before applying `offset(r = clearance)` so clearance remains in millimeters.
- Center the expanded outline within the feature footprint and extrude it through the cavity height.
- Keep SVG unsupported for laid-down shape behavior and bottom/top chamfer generation unless a robust offset-ring approach is added.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_shape_svg.scad`
- `tests/v4/assets/`

## Acceptance Criteria

- A basic custom SVG shape cuts a vertical cavity with no positive add-back remnant.
- Clearance visibly expands the cavity without changing the source-measurement scale.
- Existing square/round/hex/oct/fillet shape tests remain unchanged except for intentional validation additions.

## Result

Implemented vertical SVG feature cavities in `MakeCompartmentShape()`. The imported 2D outline is centered in the compartment, resized by real-world width with aspect ratio preserved, expanded with `offset(r = SVG_CLEARANCE_MM)` after scaling, and extruded through the feature height.

SVG cavities intentionally skip top and bottom chamfer generation for now; validation warns when a non-zero `CHAMFER_N` would otherwise apply.
