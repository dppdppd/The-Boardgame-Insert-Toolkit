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
