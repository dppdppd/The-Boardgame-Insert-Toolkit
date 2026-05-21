# Document and Test SVG Feature Shapes for Release

## Description

Add release-ready coverage and user documentation for SVG feature shapes, including authoring constraints for reliable OpenSCAD imports and examples that match BGSD-generated output.

## Scope

- Add SVG fixture assets for at least one asymmetric custom piece outline.
- Add focused CSG tests for basic SVG shape, clearance expansion, print groups, and validation warnings.
- Run render evals for the basic and clearance cases.
- Document SVG authoring rules: closed filled paths, strokes converted to paths, no raster images, and predictable aspect-ratio-preserving width scaling.
- Update parameter docs and LLM-facing guidance.

## Related Files

- `tests/v4/scad/test_shape_svg*.scad`
- `tests/v4/assets/*.svg`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/llm/BIT-DESIGN-GENERATION.md`
- `release/my_designs/examples.4.scad`

## Acceptance Criteria

- SVG feature shape behavior is covered by focused compile and render tests.
- User docs explain scaling by width and clearance expansion in millimeters.
- Release notes can describe the feature without relying on implementation details.

## Result

Added `tests/v4/assets/meeple.svg`, `tests/v4/scad/test_shape_svg.scad`, `tests/v4/scad/test_shape_svg_print_groups.scad`, and `tests/v4/scad/test_shape_svg_validation.scad`. The basic render verifies two custom SVG cavities with different clearance values; the print-group test exercises an SVG feature emitted as a separate group; validation coverage checks missing SVG block data, invalid width, negative clearance, oversized width footprint, and unsupported chamfers.

Updated `docs/guidance/BIT-PARAMETERS.md` and `docs/llm/BIT-DESIGN-GENERATION.md` with the SVG shape contract and authoring constraints.

Verification:

- `git diff --check`
- `./tests/run_tests.sh --csg-only test_shape_svg test_shape_svg_print_groups test_shape_svg_validation test_shape_round test_key_validation test_print_groups test_print_group_compartment_insert`
- `./tests/run_tests.sh --csg-only`
- `./tests/csg_regression.sh --keep-output`
- `./tests/render_eval.sh tests/v4/scad/test_shape_svg.scad`
- `openscad -o /tmp/test_shape_svg_validation.csg tests/v4/scad/test_shape_svg_validation.scad`
