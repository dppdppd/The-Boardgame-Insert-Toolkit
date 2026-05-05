# BIT Examples Catalog

Use this catalog to find the smallest relevant example before generating SCAD. Prefer focused tests for exact key usage and `release/my_designs/examples.4.scad` for larger user-facing patterns.

## General Structure

| Intent | Reference |
|---|---|
| Minimal user file | `release/my_designs/starter.scad` |
| Broad feature showcase | `release/my_designs/examples.4.scad` |
| Minimal box | `tests/v4/scad/test_box_minimal.scad` |
| Multiple boxes rendered together | `tests/v4/scad/test_combo_multi_box.scad` |
| Auto-sized boxes | `tests/v4/scad/test_box_auto_size.scad` |

## Cards

| Intent | Reference |
|---|---|
| Card tray with cutouts and lid | `tests/v4/scad/test_combo_card_tray.scad` |
| Side cutouts | `tests/v4/scad/test_cutout_sides.scad` |
| Cutout percentages | `tests/v4/scad/test_cutout_percentages.scad` |
| Labels on compartments | `tests/v4/scad/test_label_compartment.scad` |

## Tokens, Tiles, And Pieces

| Intent | Reference |
|---|---|
| Round token wells | `tests/v4/scad/test_shape_round.scad` |
| Vertical round wells | `tests/v4/scad/test_shape_round.scad` |
| Hex-shaped wells | `tests/v4/scad/test_shape_hex.scad` |
| Vertical hex tile wells | `tests/v4/scad/test_shape_hex.scad` |
| Filleted rectangular wells | `tests/v4/scad/test_shape_fillet.scad` |
| Grids of compartments | `tests/v4/scad/test_grids.scad` |
| Padding and spacing | `tests/v4/scad/test_padding.scad` |
| Positioned features | `tests/v4/scad/test_position_center.scad` |

## Lids

| Intent | Reference |
|---|---|
| No lid | `tests/v4/scad/test_box_no_lid.scad` |
| Solid lid | `tests/v4/scad/test_lid_solid.scad` |
| Inset lid | `tests/v4/scad/test_lid_inset.scad` |
| Sliding lid | `tests/v4/scad/test_lid_sliding.scad` |
| Lid fit and clearance | `tests/v4/scad/test_lid_sliding_clearance.scad` |
| Lid labels | `tests/v4/scad/test_label_lid.scad` |
| Lid patterns | `tests/v4/scad/test_lid_pattern.scad` |

## Labels

| Intent | Reference |
|---|---|
| Labels everywhere | `tests/v4/scad/test_combo_labels_everywhere.scad` |
| Stencil labels | `tests/v4/scad/test_label_stencil.scad` |
| Box side labels | `tests/v4/scad/test_label_box_sides.scad` |

## Validation

| Intent | Reference |
|---|---|
| Key validation examples | `tests/v4/scad/test_key_validation.scad` |
| Physical validation warnings | `tests/v4/scad/test_physical_validation.scad` |
| Rendering workflow | `docs/guidance/RENDERING.md` |
| Generated design validation | `docs/llm/BIT-GENERATED-DESIGN-VALIDATION.md` |

## Game-Specific Drafts

| Intent | Reference |
|---|---|
| Assumption-labeled two-deck card box with dealer button | `docs/llm/examples/two-decks-button-sliding.scad` |
| Two-deck card box assumptions and measurement notes | `docs/llm/examples/two-decks-button-sliding.assumptions.md` |
