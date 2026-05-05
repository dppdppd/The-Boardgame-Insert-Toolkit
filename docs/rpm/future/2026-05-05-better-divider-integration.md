# Improve Divider Integration With Boxes And Generated Layouts

## Description

Make dividers work as part of insert design, not only as separate renderable objects.

## Scope

- Add divider slots/channels inside boxes.
- Support generated divider layouts from card/deck compartment specs.
- Allow divider dimensions to reference matching box or feature dimensions.
- Cover removable dividers, tab clearance, and practical wall/channel tolerances.

## Related Files

- `release/lib/boardgame_insert_toolkit_lib.4.scad`
- `tests/v4/scad/test_divider_basic.scad`
- `tests/v4/scad/test_divider_advanced.scad`

## Estimate

Medium to large. Start with box divider slots before automatic divider generation.
