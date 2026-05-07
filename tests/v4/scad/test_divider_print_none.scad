// Test: suppress generated divider panels while keeping the source box rails.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_PRINT_DIVIDERS, false ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "no generated divider panels" ],
        [ BOX_SIZE_XYZ, [54, 42, 18] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "none component" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 34, 14] ],
            [ FTR_DIVIDERS,
                [ NAME, "hidden dividers" ],
                [ DIV_NUM_DIVIDERS, 1 ],
                [ DIV_THICKNESS, 1.0 ],
                [ DIV_SLOT_DEPTH, 1.5 ],
            ],
        ],
    ],
];

Make(data);
