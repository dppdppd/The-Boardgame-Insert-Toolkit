// Test: Fit-under lid — LID_FIT_UNDER_B
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "fit under lid" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID,
            [ LID_FIT_UNDER_B, t ],
            [ LID_PATTERN_RADIUS, 8 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ],
    ],
];
Make(data);
