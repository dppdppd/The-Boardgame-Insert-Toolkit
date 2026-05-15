// Test: print generated divider panels without boxes or lids.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, DIVIDERS ],

    [ OBJECT_BOX,
        [ NAME, "divider source box" ],
        [ BOX_SIZE_XYZ, [54, 42, 18] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "divider component" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 34, 14] ],
            [ FTR_DIVIDERS,
                [ NAME, "generated dividers" ],
                [ DIV_LAYOUT_BAYS, 2 ],
                [ DIV_LAYOUT_BAY_SIZE, 0 ],
                [ DIV_THICKNESS, 1.0 ],
                [ DIV_RAIL_SIZE_XYZ, [1, 1.5, 14] ],
                [ DIV_TAB_TEXT, ["SEL"] ],
                [ DIV_TAB_SIZE_XY, [12, 4] ],
                [ DIV_FRAME_NUM_COLUMNS, -1 ],
            ],
        ],
    ],
];

Make(data);
