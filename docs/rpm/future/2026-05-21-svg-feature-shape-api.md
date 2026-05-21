# Define SVG Feature Shape API and Validation

## Description

Add the user-facing data model for `SVG` as a `FTR_SHAPE` value for custom piece cavities. The API should cover SVG file input, target width in millimeters, and per-feature clearance/outline expansion.

## Scope

- Add constants for `SVG`, `SVG_FILE`, `SVG_WIDTH_MM`, and `SVG_CLEARANCE_MM`.
- Extend valid key/type validation for SVG shape fields.
- Add physical warnings for missing block data, non-positive width, negative clearance, and unsupported SVG chamfers.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `docs/llm/BIT-DESIGN-GENERATION.md`
- `tests/v4/scad/test_key_validation.scad`

## Acceptance Criteria

- SVG shape keys are validated with useful warnings and no unrecognized-key noise.
- An SVG shape block inside `FTR_SHAPE` is accepted only with a file and positive width.
- The chosen BGSD emission contract is documented in the detail file before geometry implementation starts.

## Result

Implemented the public API in `release/lib/boardgame_insert_toolkit_lib.4.scad`: `SVG` as a block value for `FTR_SHAPE`, with `SVG_FILE`, `SVG_WIDTH_MM`, and `SVG_CLEARANCE_MM` inside that block.

BGSD should emit `SVG_WIDTH_MM` inside the `FTR_SHAPE` SVG block from the measured piece width. Validation now accepts the block, type-checks the block keys, warns for missing file, non-positive width, negative clearance, oversized width footprints, and unsupported SVG chamfers.
