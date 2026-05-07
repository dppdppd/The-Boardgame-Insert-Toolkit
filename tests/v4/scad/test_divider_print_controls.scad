// Test: select a named generated divider set and print only dividers.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_PRINT_DIVIDERS, ["selected dividers"] ],
    [ G_PRINT_DIVIDERS_ONLY_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "selected source box" ],
        [ BOX_SIZE_XYZ, [54, 42, 18] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "selected component" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 34, 14] ],
            [ FTR_DIVIDERS,
                [ NAME, "selected dividers" ],
                [ DIV_NUM_DIVIDERS, 1 ],
                [ DIV_THICKNESS, 1.0 ],
                [ DIV_SLOT_DEPTH, 1.5 ],
                [ DIV_TAB_TEXT, ["SEL"] ],
                [ DIV_TAB_SIZE_XY, [12, 4] ],
                [ DIV_FRAME_NUM_COLUMNS, -1 ],
            ],
        ],
    ],

    [ OBJECT_BOX,
        [ NAME, "unselected source box" ],
        [ BOX_SIZE_XYZ, [54, 42, 18] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "unselected component" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 34, 14] ],
            [ FTR_DIVIDERS,
                [ NAME, "unselected dividers" ],
                [ DIV_NUM_DIVIDERS, 1 ],
                [ DIV_THICKNESS, 1.0 ],
                [ DIV_SLOT_DEPTH, 1.5 ],
            ],
        ],
    ],
];

Make(data);
