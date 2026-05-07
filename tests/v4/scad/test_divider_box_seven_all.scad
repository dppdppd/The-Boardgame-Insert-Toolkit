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
                [ DIV_NUM_DIVIDERS, 7 ],
                [ DIV_THICKNESS, 4.0 ],
                [ DIV_SLOT_DEPTH, 1 ],
                [ DIV_TAB_TEXT, ["1", "2", "3", "4", "5", "6", "7"] ],
              //  [ DIV_TAB_TEXT_SIZE, 1 ],
                [ DIV_TAB_SIZE_XY, [8, 4] ],
                [ DIV_TAB_CYCLE, 7 ],
                [ DIV_FRAME_NUM_COLUMNS, -1 ],
            ],
        ],
    ],
];

Make(data);
