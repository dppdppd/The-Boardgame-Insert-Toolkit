# BIT Common Parameters Quick Reference

All parameters for the v4 data array format. See `release/lib/boardgame_insert_toolkit_lib.4.scad` for full definitions.

## Element-level (inside OBJECT_BOX)

`NAME`, `BOX_SIZE_XYZ`, `BOX_FEATURE`, `BOX_LID`, `BOX_NO_LID_B`, `BOX_STACKABLE_B`, `CHAMFER_N`, `ENABLED_B`

## Feature-level (inside BOX_FEATURE)

`FTR_COMPARTMENT_SIZE_XYZ`, `FTR_NUM_COMPARTMENTS_XY`, `FTR_SHAPE` (SQUARE/HEX/HEX2/OCT/OCT2/ROUND/FILLET), `FTR_SHAPE_ROTATED_B`, `FTR_SHAPE_VERTICAL_B`, `FTR_PADDING_XY`, `FTR_PADDING_HEIGHT_ADJUST_XY`, `FTR_MARGIN_FBLR`, `FTR_CUTOUT_SIDES_4B`, `FTR_CUTOUT_CORNERS_4B`, `FTR_CUTOUT_HEIGHT_PCT`, `FTR_CUTOUT_DEPTH_PCT`, `FTR_CUTOUT_WIDTH_PCT`, `FTR_CUTOUT_BOTTOM_B`, `FTR_CUTOUT_BOTTOM_PCT`, `FTR_CUTOUT_TYPE` (INTERIOR/EXTERIOR/BOTH), `FTR_SHEAR`, `FTR_FILLET_RADIUS`, `FTR_PEDESTAL_BASE_B`, `CHAMFER_N`, `POSITION_XY`, `ROTATION`

## Lid-level (inside BOX_LID)

`LID_TYPE` (`LID_CAP`/`LID_INSET`/`LID_SLIDING`), `LID_SLIDE_SIDE` (`FRONT`/`BACK`/`LEFT`/`RIGHT`, default `FRONT`), `LID_FRAME_WIDTH` (default wall thickness; 0 omits the extra patterned sliding-lid frame), `LID_SOLID_B`, `LID_HEIGHT`, `LID_FIT_UNDER_B`, `LID_INSET_B` (legacy boolean used when `LID_TYPE` is omitted), `LID_PATTERN_RADIUS`, `LID_PATTERN_N1/N2`, `LID_PATTERN_ANGLE`, `LID_PATTERN_ROW_OFFSET/COL_OFFSET`, `LID_PATTERN_THICKNESS`, `LID_CUTOUT_SIDES_4B`, `LID_LABELS_INVERT_B`, `LID_SOLID_LABELS_DEPTH`, `LID_LABELS_BG_THICKNESS`, `LID_LABELS_BORDER_THICKNESS`, `LID_STRIPE_WIDTH/SPACE`, `LID_TABS_4B`

`LID_SLIDING` creates a sliding panel with matching box rails and a stop on the opposite side from `LID_SLIDE_SIDE`. The rail groove has a horizontal bottom and printable 45-degree top, and the top of that 45-degree wall is the top of the groove. The groove extends halfway into the wall so the lid rests on a wall shelf under the wedge. The lid edge has the matching bevel, and the slide opening has a top-open lead-in rather than a covered slot. Patterned sliding lids include a perimeter frame for rigidity, clipped to the same wedge edges and chamfered corners as solid sliding lids. Sliding lids include a 45-degree friction detent on the top of the opening-side wall with a matching groove in the underside of the lid, use the global detent settings for size, ignore `LID_HEIGHT` and `LID_FIT_UNDER_B`, and can use the normal solid, pattern, and label parameters.

## Label-level (inside BOX_LID, BOX_FEATURE, or box-level)

`LBL_TEXT`, `LBL_SIZE` (number or AUTO), `LBL_PLACEMENT` (FRONT/BACK/LEFT/RIGHT/FRONT_WALL/BACK_WALL/LEFT_WALL/RIGHT_WALL/CENTER/BOTTOM), `LBL_FONT`, `LBL_DEPTH`, `LBL_SPACING`, `LBL_IMAGE`, `ROTATION`, `POSITION_XY`

## Divider-level

`DIV_TAB_TEXT`, `DIV_TAB_SIZE_XY`, `DIV_TAB_RADIUS`, `DIV_TAB_CYCLE`, `DIV_TAB_CYCLE_START`, `DIV_TAB_TEXT_SIZE/FONT/SPACING`, `DIV_TAB_TEXT_EMBOSSED_B`, `DIV_FRAME_SIZE_XY`, `DIV_FRAME_NUM_COLUMNS`, `DIV_FRAME_COLUMN`, `DIV_FRAME_TOP/BOTTOM/RADIUS`, `DIV_THICKNESS`

## Globals (as `[G_*, value]` pairs in data array)

`G_PRINT_LID_B`, `G_PRINT_BOX_B`, `G_ISOLATED_PRINT_BOX`, `G_VISUALIZATION_B`, `G_VALIDATE_KEYS_B`, `G_WALL_THICKNESS`, `G_TOLERANCE`, `G_TOLERANCE_DETENT_POS`, `G_DEFAULT_FONT`, `G_PRINT_MMU_LAYER`

File-scope `$g_*` variables provide defaults; data array entries override them via `Make()`.

## Gotchas

- **`FTR_SHAPE_VERTICAL_B = true` does nothing without an explicit `FTR_SHAPE`.** The default `FTR_SHAPE` is `SQUARE`, and the vertical flag is ignored for square cavities. To get a round vertical cavity (e.g. for a cylindrical token stack), set `FTR_SHAPE = ROUND` and `FTR_SHAPE_VERTICAL_B = true` together. Same applies for vertical hex / oct — pair with `FTR_SHAPE = HEX` (or `HEX2`/`OCT`/`OCT2`).
