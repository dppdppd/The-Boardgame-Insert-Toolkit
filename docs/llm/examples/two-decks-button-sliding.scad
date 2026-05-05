// Assumption-labeled BIT draft for a sliding-lid box that stores two decks
// of cards plus one round dealer button. Replace measurements before printing.
// See two-decks-button-sliding.assumptions.md.

include <../../../release/lib/boardgame_insert_toolkit_lib.4.0.8.scad>;

inch = 25.4;
wall = 1.5;
tolerance = 0.15;
clearance_xy = 3;
clearance_z = 2;

// Default to a boxed/sleeved poker-deck envelope. Measure your real decks.
deck_x = 2.625 * inch;
deck_y = 3.625 * inch;
deck_z = 0.75 * inch;

button_diameter = 55;
button_z = 5;

deck_well_x = deck_x + clearance_xy;
deck_well_y = deck_y + clearance_xy;
deck_well_z = deck_z + clearance_z;

button_well = button_diameter + clearance_xy;
button_well_z = button_z + clearance_z;

tray_x = 2 * deck_well_x + button_well + 5 * wall;
tray_y = max(deck_well_y, button_well) + 4 * wall;
tray_z = max(deck_well_z, button_well_z) + 2 * wall;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ G_VALIDATE_KEYS_B, true ],
    [ G_WALL_THICKNESS, wall ],
    [ G_TOLERANCE, tolerance ],
    [ G_DEFAULT_FONT, "Liberation Sans:style=Bold" ],

    [ OBJECT_BOX,
        [ NAME, "Two decks plus dealer button" ],
        [ BOX_SIZE_XYZ, [tray_x, tray_y, tray_z] ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, t ],
            [ LABEL,
                [ LBL_TEXT, "CARDS" ],
                [ LBL_PLACEMENT, CENTER ],
                [ LBL_SIZE, AUTO ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [deck_well_x, deck_well_y, deck_well_z] ],
            [ FTR_PADDING_XY, [wall, wall] ],
            [ POSITION_XY, [wall, wall] ],
            [ FTR_CUTOUT_SIDES_4B, [t, t, f, f] ],
            [ FTR_CUTOUT_DEPTH_PCT, 30 ],
            [ FTR_CUTOUT_WIDTH_PCT, 45 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [button_well, button_well, button_well_z] ],
            [ FTR_SHAPE, ROUND ],
            [ FTR_SHAPE_VERTICAL_B, t ],
            [ POSITION_XY, [2 * deck_well_x + 3 * wall, wall] ],
            [ LABEL,
                [ LBL_TEXT, "BUTTON" ],
                [ LBL_PLACEMENT, BOTTOM ],
                [ LBL_SIZE, 6 ],
            ],
        ],
    ],
];

Make(data);
