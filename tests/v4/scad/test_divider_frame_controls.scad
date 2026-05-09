// Test: FTR_DIVIDERS frame controls and exact small tab sizing.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "feature divider frame and tab controls" ],
        [ BOX_SIZE_XYZ, [78, 46, 20] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "small exact tab divider" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [68, 34, 14] ],
            [ FTR_DIVIDERS,
                [ NAME, "framed generated divider" ],
                [ DIV_AXIS, X ],
                [ DIV_LAYOUT_BAYS, 2 ],
                [ DIV_LAYOUT_BAY_SIZE, 0 ],
                [ DIV_THICKNESS, 1.0 ],
                [ DIV_RAIL_SIZE_XYZ, [1.0, 1.4, MAX] ],
                [ DIV_TAB_TEXT, [""] ],
                [ DIV_TAB_SIZE_XY, [8, 2] ],
                [ DIV_TAB_RADIUS, 1 ],
                [ DIV_FRAME_NUM_COLUMNS, 1 ],
                [ DIV_FRAME_COLUMN, 2 ],
                [ DIV_FRAME_TOP, 2 ],
                [ DIV_FRAME_BOTTOM, 2 ],
                [ DIV_FRAME_RADIUS, 1.5 ],
            ],
        ],
    ],
];

Make(data);
