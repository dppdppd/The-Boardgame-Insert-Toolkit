// Test: g_isolated_print_box — only render the named box
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "target box" ],
    [ OBJECT_BOX,
        [ NAME, "hidden box" ],
        [ BOX_SIZE_XYZ, [40, 40, 15] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [36, 36, 13] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "target box" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [3, 3] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [16, 16, 18] ],
        ],
    ],
];
Make(data);
