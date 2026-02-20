// Test: g_print_lid_b=true, g_print_box_b=false — should only render the lid
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, false ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "lid only" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_LID,
            [ LID_PATTERN_RADIUS, 8 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
        ],
    ],
];
Make(data);
