// Test: simple divider box with seven generated divider panels printed by default.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "seven divider box" ],
        [ BOX_SIZE_XYZ, [104, 44, 18] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "single row compartment" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [96, 34, 14] ],
            [ FTR_DIVIDERS,
                [ NAME, "all seven dividers" ],
                [ DIV_LAYOUT_BAYS, 8 ],
                [ DIV_LAYOUT_BAY_SIZE, 0 ],
                [ DIV_THICKNESS, 0.4 ],
                [ DIV_RAIL_SIZE_XYZ, [1, 1, 14] ],
                [ DIV_TAB_SIZE_XY, [0.4, 1.0] ],
            ],
        ],
    ],
];

Make(data);
