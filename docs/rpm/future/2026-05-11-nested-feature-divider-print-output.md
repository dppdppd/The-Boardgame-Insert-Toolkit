# Complete Nested Feature Divider Print Output

## Description

Nested `BOX_FEATURE` geometry now supports child cavities, child labels, cutouts, `FEATURE_GROUP`, and `FEATURE_COPY`, but the library still warns that nested feature divider print output is incomplete.

## Scope

- Define expected print behavior for `FTR_DIVIDERS` inside nested child features.
- Decide how generated loose divider panels should be selected, named, and laid out when their source feature is nested or copied.
- Ensure nested/copy transforms do not leak into detached divider print layout.
- Add render and CSG tests for box-side rails plus generated loose divider panels from nested children.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_nested_feature_*.scad`
- `tests/v4/scad/test_feature_copy_*.scad`

## Acceptance Criteria

- Nested child `FTR_DIVIDERS` either fully generate expected loose print panels or emit a narrower validation warning that documents the remaining unsupported path.
- `G_PRINT_TYPES` behavior for generated divider panels is documented for nested and copied features.
- Full CSG passes, and focused full renders cover nested divider rails/panels.
