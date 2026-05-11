# Add Subcomponents For Nesting Features Inside Features

## Description

Support nested feature definitions so a `BOX_FEATURE` can contain smaller child features instead of forcing every cut/addition to be a top-level box feature.

## Scope

- Define a child-feature data shape and coordinate system relative to its parent feature.
- Support nesting for common use cases such as token wells inside a card tray, relief cuts inside a shaped cavity, and localized labels/cutouts.
- Validate parent/child bounds, rotations, shear interactions, and inherited defaults.
- Keep the top-level flat data format backwards compatible.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `tests/v4/scad/test_multi_component.scad`
- `tests/v4/scad/test_position_rotation.scad`

## Estimate

Large. Needs a small spec before implementation because it touches data modeling and the CSG pipeline.

## Plan

Inspection notes:

- `BOX_FEATURE` is currently valid only at box level. A feature table may contain `LABEL` and `FTR_DIVIDERS` subgroups, but not another `BOX_FEATURE`.
- Feature geometry is built by `MakeBox()` through three component stages: `component_subtractions`, `component_additions`, and `final_component_subtractions`.
- The "additions" stage is not a positive add to the final box. It is a mask removed from the subtraction volume so floors, partitions, chamfers, fillets, and divider rails remain solid. Nested child additions therefore must be included in the parent subtraction mask; otherwise the parent cavity will have already removed the child walls/floors.
- Existing validation already has component size/position helpers and transformed footprint checks for `POSITION_XY`, `ROTATION`, and `FTR_SHEAR`, but those helpers assume box coordinates and wall-thickness offsets.

### Data Shape

Use repeated nested `BOX_FEATURE` entries inside a parent `BOX_FEATURE`:

```scad
[ BOX_FEATURE,
    [ NAME, "card tray" ],
    [ FTR_COMPARTMENT_SIZE_XYZ, [66, 92, 12] ],
    [ POSITION_XY, [CENTER, CENTER] ],

    [ BOX_FEATURE,
        [ NAME, "token well" ],
        [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 18] ],
        [ FTR_SHAPE, ROUND ],
        [ FTR_SHAPE_VERTICAL_B, true ],
        [ POSITION_XY, [4, 4] ]
    ]
]
```

This keeps the top-level data array flat and backward compatible: existing designs are unchanged, and `BOX_FEATURE` in a feature table is currently invalid, so accepting it is an additive schema change.

Initial scope should support one or more child `BOX_FEATURE` entries at any nesting depth, but implementation can land one depth first behind recursive helper structure. Do not introduce a separate `FTR_CHILDREN` wrapper unless BGSD needs a list-valued wrapper; repeated key-value entries are consistent with current `BOX_FEATURE`, `LABEL`, and `FTR_DIVIDERS` conventions.

### Coordinate System

- A child feature's local origin is the parent feature's local front-left-bottom component origin before the parent transform is applied.
- Child `POSITION_XY` uses the same value types as top-level features:
  - numeric values are millimeters from the parent feature's local front-left edge;
  - `CENTER` centers the transformed child footprint in the parent feature's local component footprint;
  - `MAX` places the transformed child footprint against the parent feature's local back/right edge.
- Numeric child positions do not receive `BOX_WALL_THICKNESS`; the parent feature transform has already moved into box interior coordinates.
- Child `ROTATION` is around the child feature center after child local placement. Parent transforms wrap child transforms, so the effective order is child shear, child placement, child rotation, parent shear, parent placement, parent rotation.
- Child `FTR_SHEAR` is local to the child. Parent shear is inherited only as an outer transform, not copied into the child value.
- Child `FTR_COMPARTMENT_SIZE_XYZ[z]` keeps the existing feature meaning: cavity depth measured from the box opening/top reference used by normal components. It is not a delta from the parent cavity floor. This preserves equivalence with a manually placed overlapping top-level feature and avoids adding a Z-position API in the first implementation.
- Parent `ENABLED_B = false` disables all descendants. Parent `DEBUG_B` may wrap descendants for visualization, but child `DEBUG_B` remains independently usable.
- Default inheritance should be narrow:
  - child `CHAMFER_N` falls back to parent `CHAMFER_N`, then box `CHAMFER_N`;
  - child size/count/padding/margins/shape/cutout defaults stay the same as top-level feature defaults;
  - rotations and shear compose as transforms rather than inheriting numeric values;
  - labels and `FTR_DIVIDERS` inside a child belong to that child only.

Per-compartment repetition should be deferred unless a concrete BGSD/user case requires it. If needed later, add an explicit key such as `FTR_CHILD_SCOPE` with values `COMPONENT` and `EACH_COMPARTMENT`; do not overload the default coordinate system.

### Validation Strategy

Schema validation:

1. Add `BOX_FEATURE` to `__VALID_COMPONENT_KEYS`.
2. Add a recursive `__ValidateNestedFeatures(component, ctx, depth)` that:
   - validates each child with `__VALID_COMPONENT_KEYS`;
   - runs `__ValidateComponentTypes`, `__ValidateLabels`, and `__ValidateFeatureDividers` for each child;
   - recurses into grandchildren;
   - includes index-based context such as `box "x" > component[3] > component[7]`.
3. Add a conservative maximum validation depth constant or warning threshold to prevent accidental runaway compile costs from generated data.

Physical validation:

1. Refactor current component footprint helpers so they can evaluate in either box coordinates or parent-local coordinates. Parent-local checks use wall offset `0`.
2. Check every child transformed footprint against the parent feature's local component footprint after child rotation/shear expansion.
3. For parent-local bounds, use the parent feature footprint `[0, 0]` to `[__cmp_auto_size(parent, X), __cmp_auto_size(parent, Y)]`. This intentionally validates against the component footprint, not each compartment, for the initial component-scoped API.
4. Run existing global box bounds validation for every resolved child transform where the parent transform can be evaluated. If exact nested rotation/shear composition is too large for the first slice, emit a conservative physical warning when parent shear combines with child rotation/shear and document that bounds are approximate for that combination.
5. Warn, do not hard fail, for:
   - child footprint outside parent footprint;
   - child cavity depth greater than box usable depth;
   - child transform combinations that physical validation cannot evaluate exactly;
   - nested `FTR_DIVIDERS` layouts that exceed the child compartment;
   - child overlap with sibling child footprints under the same parent.

### CSG Implementation Sequence

1. Add helper discovery functions only:
   - `__component_child_count(component)`;
   - `__component_child_at(component, n)`;
   - `__component_has_children(component)`.
   Add no user docs yet if geometry is not implemented.
2. Split current `MakeLayer()` component internals into raw local modules that do not apply top-level `PositionInnerLayer()` themselves:
   - component subtraction volume;
   - component addition mask;
   - component final subtraction volume;
   - feature divider preview/print handling can stay separate initially.
3. Replace the top-level per-component subtractor with a tree builder:
   - main subtractor is `difference() { union(component subtraction volumes for parent and descendants); union(component addition masks for parent and descendants); }`;
   - final subtractor is `union(component final subtractions for parent and descendants)`;
   - child geometry is positioned by a `PositionChildLayer(parent, child)` transform inside the parent local frame.
4. Preserve existing no-child output. With no nested `BOX_FEATURE`, the generated geometry must be identical to the current pipeline.
5. Add nested child labels and cutouts through the same final-subtraction tree. Child labels use the child compartment frame. Box-level and lid labels are unchanged.
6. Add nested `FTR_DIVIDERS` support after basic nested geometry. Rails inside child features need to participate in the child addition mask; loose generated divider panel print layout can remain top-level-only until selector/name semantics are specified.
7. Update `docs/guidance/BIT-PARAMETERS.md` only when geometry support exists, including examples and the limitation that child depth is still box-top referenced.

### Test Strategy

Before any implementation patch, render current baselines for affected existing tests:

- `./tests/run_tests.sh test_multi_component`
- `./tests/run_tests.sh test_position_rotation`

Focused new tests:

- `test_nested_feature_basic.scad`: one parent cavity with one round child well. Include a top-level-equivalent sibling or companion case for visual comparison.
- `test_nested_feature_child_partitions.scad`: child with `FTR_NUM_COMPARTMENTS_XY` greater than `[1, 1]` inside a parent, proving child addition masks preserve child partitions/walls.
- `test_nested_feature_transform.scad`: parent rotation plus child `POSITION_XY = [CENTER, MAX]` and child rotation.
- `test_nested_feature_validation.scad`: malformed child key/type, child outside parent local footprint, and unsupported/approximate shear interaction warning.
- `test_nested_feature_labels_cutouts.scad`: child label and side/corner/bottom cutouts are clipped to child/parent expectations.

Verification per implementation slice:

- Run the focused new test with full renders, not just CSG, so STL and seven PNG views are written.
- Run `./tests/run_tests.sh --csg-only` after every library change.
- For refactor-only slices, compare before/after PNGs for `test_multi_component` and `test_position_rotation` and require no visual geometry change.

### Acceptance Criteria

- Existing designs without nested `BOX_FEATURE` entries compile and render identically.
- A nested child feature renders in the same physical location as the equivalent manually positioned top-level feature when there are no child partitions to restore.
- A nested child with partitions/floors preserves those solid masks inside a parent cavity.
- Key/type validation recursively reports nested child context.
- Physical validation warns for child out-of-parent bounds and for transform combinations it cannot evaluate exactly.
- `docs/guidance/BIT-PARAMETERS.md` documents the child feature shape, coordinate system, inherited defaults, and current limitations before the feature is considered user-facing.

## Worker Result

Summary:

- Implemented the first validation/scaffolding slice for nested `BOX_FEATURE` entries inside component tables.
- Added component child discovery helpers: `__component_child_count(component)`, `__component_child_at(component, n)`, and `__component_has_children(component)`.
- Added `BOX_FEATURE` to component-valid keys and recursive nested child key/type validation for component keys, labels, and feature dividers.
- Added explicit `BIT-NESTED-FEATURE` warnings so accepted nested children do not silently imply geometry support; nested geometry is still not rendered.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_nested_feature_validation.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- `./tests/run_tests.sh --csg-only test_nested_feature_validation` - passed with expected warnings.
- `./tests/run_tests.sh test_nested_feature_validation` - passed with expected warnings and generated renders.
- `openscad -o /tmp/bit_nested_feature_validation.csg tests/v4/scad/test_nested_feature_validation.scad 2>&1 | grep 'BGSD_WARNING'` - verified recursive child and grandchild contexts.
- `./tests/run_tests.sh --csg-only` - 76 passed, 0 failed, 20 warning-reporting tests.

Remaining risks or follow-ups:

- Nested child geometry, physical child bounds, sibling overlap checks, and nested child labels/cutouts/divider geometry are not implemented yet.
- User-facing parameter docs were intentionally not updated because this slice only accepts and validates schema.
- The nested-geometry limitation warning is emitted through validation, so designs that disable validation can still define ignored child geometry without the warning.

## Worker Result

Summary:

- Completed a geometry-neutral CSG preparation slice for nested feature work.
- Extracted the raw local `component_subtractions` geometry from `InnerLayer()` into `MakeComponentSubtractionVolume()` inside `MakeLayer()`.
- Preserved the existing `PositionInnerLayer()` dispatch path, so designs without nested child geometry should generate identical output.
- Did not implement nested child geometry in this slice.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- Before patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven baseline renders.
- Before patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven baseline renders.
- After patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven renders.
- After patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven renders.
- Compared before/after PNGs for both affected tests with `cmp`; all 14 render files matched byte-for-byte.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.
- `./tests/run_tests.sh --csg-only` - 76 passed, 0 failed, 20 warning-reporting tests.

Remaining risks or follow-ups:

- The addition-mask and final-subtraction branches still need equivalent raw local extraction before a child-feature tree builder can call all three stages directly.
- The top-level per-component subtractor still uses the flat, no-child pipeline; nested child geometry remains accepted for validation only and is not rendered.
- Next safe micro-slice: extract `component_additions` into a raw local `MakeComponentAdditionMask()` module, run the same two baseline render comparisons, then full CSG.

## Worker Result

Summary:

- Completed a geometry-neutral CSG preparation slice for nested feature work.
- Extracted the raw local `component_additions` geometry from `InnerLayer()` into `MakeComponentAdditionMask()` inside `MakeLayer()`.
- Preserved the existing `PositionInnerLayer()` dispatch path, so designs without nested child geometry generate identical output.
- Did not implement nested child geometry in this slice.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- Before patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven baseline renders copied to `/tmp/bit-subcomponents-additions-baseline/test_multi_component/`.
- Before patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven baseline renders copied to `/tmp/bit-subcomponents-additions-baseline/test_position_rotation/`.
- After patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven renders.
- After patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven renders.
- Compared before/after PNGs for both affected tests with `cmp`; all 14 render files matched byte-for-byte.
- `./tests/run_tests.sh --csg-only` - 76 passed, 0 failed, 20 warning-reporting tests.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.

Remaining risks or follow-ups:

- The final-subtraction branch still needs equivalent raw local extraction before a child-feature tree builder can call all three stages directly.
- The top-level per-component subtractor still uses the flat, no-child pipeline; nested child geometry remains accepted for validation only and is not rendered.
- Next safe micro-slice: extract `final_component_subtractions` into a raw local module, run the same two baseline render comparisons, then full CSG.

## Worker Result

Summary:

- Completed the final geometry-neutral CSG preparation slice for nested feature work.
- Extracted the raw local `final_component_subtractions` geometry from `InnerLayer()` into `MakeComponentFinalSubtractions()` inside `MakeLayer()`.
- Preserved the existing `PositionInnerLayer()` dispatch path, so designs without nested child geometry generate identical output.
- Did not implement nested child geometry in this slice.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- Before patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven baseline renders copied to `/tmp/bit-subcomponents-final-baseline/test_multi_component/`.
- Before patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven baseline renders copied to `/tmp/bit-subcomponents-final-baseline/test_position_rotation/`.
- After patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven renders.
- After patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven renders.
- Compared before/after PNGs for both affected tests with `cmp`; all 14 render files matched byte-for-byte.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.
- `./tests/run_tests.sh --csg-only` - 76 passed, 0 failed, 20 warning-reporting tests.

Remaining risks or follow-ups:

- Nested child geometry is still not implemented; nested child features remain accepted for validation only and are not rendered.
- All three raw component geometry stages are now extracted, so the next implementation slice can introduce a child-feature tree builder while preserving the no-child path.
- Physical child bounds, sibling overlap checks, and nested child labels/cutouts/divider geometry remain follow-up work.

## Worker Result

Summary:

- Implemented the first child-feature CSG tree builder inside `MakeLayer()`.
- Nested enabled `BOX_FEATURE` entries with renderable values now participate in the three raw component geometry stages: subtraction volume, addition mask, and final subtractions.
- Child `POSITION_XY`, `ROTATION`, and `FTR_SHEAR` apply in the parent component's local frame, without the top-level wall-thickness offset.
- Added a guarded recursive path using `NESTED_FEATURE_VALIDATION_MAX_DEPTH`; malformed nested children remain validation-only instead of breaking geometry generation.
- Updated the `BIT-NESTED-FEATURE` warning text so it describes experimental partial geometry support instead of saying child geometry is never rendered.
- Added `test_nested_feature_basic.scad` to render a visible child round well inside a parent square cavity.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_nested_feature_basic.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- Before patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven baseline renders copied to `/tmp/bit-subcomponents-tree-baseline/test_multi_component/`.
- Before patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven baseline renders copied to `/tmp/bit-subcomponents-tree-baseline/test_position_rotation/`.
- `./tests/run_tests.sh --csg-only test_nested_feature_basic` - passed with the expected `BIT-NESTED-FEATURE` warning.
- `./tests/run_tests.sh --csg-only test_nested_feature_validation` - passed with expected validation warnings.
- `./tests/run_tests.sh test_nested_feature_basic` - passed with the expected `BIT-NESTED-FEATURE` warning and generated seven renders.
- After patching, `./tests/run_tests.sh test_multi_component` - passed, 0 warnings, generated seven renders.
- After patching, `./tests/run_tests.sh test_position_rotation` - passed, 0 warnings, generated seven renders.
- Compared before/after PNGs for both affected no-child tests with `cmp`; all 14 render files matched byte-for-byte.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad tests/v4/scad/test_nested_feature_basic.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.
- `./tests/run_tests.sh --csg-only` - 77 passed, 0 failed, 21 warning-reporting tests.

Remaining risks or follow-ups:

- Basic recursive child geometry is implemented, but physical child bounds, sibling overlap checks, and exact transformed-footprint validation remain follow-up work.
- Nested labels, cutouts, feature divider print output, and complex divider semantics are still experimental/incomplete; any support there is incidental to the raw tree path.
- Nested children with malformed geometry-critical values are skipped by the render guard after validation reports warnings.

## Worker Result

Summary:

- Test-only slice; no library fix was needed.
- Added a focused nested child partition render test where a centered nested `BOX_FEATURE` uses `FTR_NUM_COMPARTMENTS_XY = [2, 2]` inside a deeper parent cavity.
- The generated top and isometric renders show the child 2x2 floor/partition grid preserved inside the parent cavity, proving child addition masks are included in the nested child tree.

Files changed:

- `tests/v4/scad/test_nested_feature_child_partitions.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- `./tests/run_tests.sh test_nested_feature_child_partitions` - passed with the expected `BIT-NESTED-FEATURE` warning and generated seven renders.
- Visual check of `tests/v4/renders/test_nested_feature_child_partitions_top.png` and `tests/v4/renders/test_nested_feature_child_partitions_iso.png` confirmed visible child floors/partitions inside the parent cavity.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad tests/v4/scad/test_nested_feature_child_partitions.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.
- `./tests/run_tests.sh --csg-only` - 78 passed, 0 failed, 22 warning-reporting tests.

Remaining risks or follow-ups:

- Physical child bounds remain out of scope.
- Sibling overlap checks remain out of scope.
- Nested labels, cutouts, divider print semantics, and user-facing docs remain out of scope.

## Worker Result

Summary:

- Added a focused nested transform render test for parent rotation plus child `POSITION_XY = [CENTER, MAX]` and child rotation.
- Included a narrowly scoped library fix in the nested child `PositionChildLayer` path: child `CENTER`/`MAX` placement now accounts for the child's transformed footprint after local shear/rotation, while numeric child positions remain local-origin based.
- The first transform render exposed the bug visually: the rotated child tray breached the parent back edge. After the fix, top and iso renders show the child tray inside the rotated parent footprint.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_nested_feature_transform.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- Before patching the library, `./tests/run_tests.sh test_nested_feature_transform` - passed with the expected `BIT-NESTED-FEATURE` warning and generated seven renders; visual inspection of top/iso showed the child transform bug.
- Before patching the library, `./tests/run_tests.sh test_multi_component test_position_rotation` - passed, 0 warnings, generated baseline renders copied to `/tmp/bit-nested-transform-baseline/`.
- After patching the library, `./tests/run_tests.sh test_nested_feature_transform` - passed with the expected `BIT-NESTED-FEATURE` warning and generated seven renders; visual inspection of top/iso confirmed the child tray stays inside the parent footprint.
- After patching the library, `./tests/run_tests.sh test_multi_component test_position_rotation` - passed, 0 warnings, generated seven renders for each test.
- Compared before/after PNGs for `test_multi_component` and `test_position_rotation` with `cmp`; all 14 render files matched byte-for-byte.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad tests/v4/scad/test_nested_feature_transform.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.
- `./tests/run_tests.sh --csg-only` - 79 passed, 0 failed, 23 warning-reporting tests.

Remaining risks or follow-ups:

- Physical child bounds remain out of scope.
- Sibling overlap checks remain out of scope.
- Nested labels/cutouts/divider print semantics remain out of scope.
- User-facing docs remain out of scope.

## Worker Result

Summary:

- Implemented parent-local physical validation warnings for nested `BOX_FEATURE` children.
- Added helper functions that evaluate child transformed XY footprints in the parent component's local frame, matching the nested geometry `CENTER`/`MAX` placement behavior and preserving numeric child positions as parent-local values.
- Added recursive nested physical validation for child out-of-parent bounds and sibling child footprint overlap under the same parent.
- Updated `test_nested_feature_validation.scad` to emit the new nested physical warnings.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_nested_feature_validation.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- `openscad -o /tmp/bit_nested_feature_validation.csg tests/v4/scad/test_nested_feature_validation.scad 2>&1 | rg 'BGSD_WARNING|BIT-PHYSICAL|nested'` - verified nested context plus `BIT-PHYSICAL` warnings for child bounds and sibling overlap.
- `./tests/run_tests.sh test_nested_feature_validation` - passed with expected warnings and generated seven renders.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad tests/v4/scad/test_nested_feature_validation.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.
- `./tests/run_tests.sh --csg-only` - 79 passed, 0 failed, 23 warning-reporting tests.

Remaining risks or follow-ups:

- Nested child validation is parent-local only in this slice; composed global parent+child footprint validation remains out of scope.
- Nested labels, cutouts, divider print semantics, and user-facing docs remain out of scope.
- Invalid child geometry-critical values are still skipped by guard conditions after type/key warnings.

## Worker Result

Summary:

- Verified nested child labels and representative child side/corner/bottom cutouts through the existing nested final-subtraction tree; no geometry fix was needed.
- Added a focused render test with a parent cavity, one nested child with a child-local floor label, and one nested child with side, corner, and bottom cutouts.
- Updated the `BIT-NESTED-FEATURE` warning text to remove labels/cutouts from the incomplete list while keeping nested feature divider print output called out as incomplete.
- Did not update user-facing `docs/guidance/BIT-PARAMETERS.md`; nested feature docs should wait until divider print semantics and release readiness are settled.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_nested_feature_labels_cutouts.scad`
- `docs/rpm/future/2026-05-05-subcomponents-nesting-features.md`

Verification run:

- `./tests/run_tests.sh test_nested_feature_labels_cutouts` - passed with expected `BIT-NESTED-FEATURE` warnings and generated seven renders.
- Visual check of `tests/v4/renders/test_nested_feature_labels_cutouts_top.png` and `tests/v4/renders/test_nested_feature_labels_cutouts_iso.png` confirmed the nested child `X` label and the nested child side/corner/bottom cutouts render inside the parent cavity.
- `./tests/run_tests.sh --csg-only test_nested_feature_labels_cutouts` - passed with expected warnings.
- `git diff --check -- release/lib/boardgame_insert_toolkit_lib.4.scad tests/v4/scad/test_nested_feature_labels_cutouts.scad docs/rpm/future/2026-05-05-subcomponents-nesting-features.md` - passed.
- `./tests/run_tests.sh --csg-only` was attempted multiple times but the session was killed before the runner printed its final summary; no failures were reported before interruption. A follow-up targeted run for the tests not reached in the first interrupted output, `./tests/run_tests.sh --csg-only test_shear test_stacking test_validation_flags`, passed.

Remaining risks or follow-ups:

- Nested feature divider print output remains incomplete and intentionally out of scope for this slice.
- User-facing parameter docs remain a follow-up; this slice only updates the experimental warning and adds render-backed coverage.
- The all-in-one CSG runner needs a clean final-summary rerun when the environment stops killing the long command.

## Worker Result

Summary:

- Completed and released the practical user-facing nested feature surface.
- Fixed nested child CSG so child negative trees cut into restored parent material and child additions are clipped at the parent floor.
- Replaced abstract nested tests with practical tray/well examples.
- Added `FEATURE_GROUP` as a non-geometry transform wrapper for grouped child features.
- Added `FEATURE_COPY` plus `FEATURE_REFERENCE` to repeat a named `BOX_FEATURE` or `FEATURE_GROUP` with a new outer position/rotation.
- Published `v4.6.1`, `v4.7.0`, and `v4.8.0`.

Files changed:

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `docs/guidance/BIT-PARAMETERS.md`
- `release/lib/boardgame_insert_toolkit_lib.4.6.1.scad`
- `release/lib/boardgame_insert_toolkit_lib.4.7.0.scad`
- `release/lib/boardgame_insert_toolkit_lib.4.8.0.scad`
- `release/my_designs/starter.scad`
- `release/my_designs/examples.4.scad`
- `tests/v4/scad/test_nested_feature_*.scad`
- `tests/v4/scad/test_feature_group_*.scad`
- `tests/v4/scad/test_feature_copy_*.scad`

Verification run:

- `./tests/run_tests.sh --csg-only` - 86 passed, 0 failed, 27 warning-reporting tests after `FEATURE_COPY`.
- `./tests/run_tests.sh test_feature_copy_basic test_feature_copy_group test_feature_copy_nested test_feature_copy_validation` - 4 passed, 0 failed, 2 expected warning-reporting tests.
- `./scripts/package-release.sh --minor` smoke-compiled shipped starter/example files for `v4.8.0`.
- GitHub release `v4.8.0` published with `boardgame_insert_toolkit_lib.4.8.0.scad`.

Remaining risks or follow-ups:

- Nested feature divider print output remains incomplete/experimental and is tracked separately in `2026-05-11-nested-feature-divider-print-output.md`.
