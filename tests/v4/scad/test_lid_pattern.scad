// Test: Pattern lid — default hex pattern with various radius values
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "default pattern lid" ],
        [ BOX_SIZE_XYZ, [60, 60, 15] ],
        [ BOX_LID,
            [ LID_PATTERN_RADIUS, 8 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "small pattern" ],
        [ BOX_SIZE_XYZ, [60, 60, 15] ],
        [ BOX_LID,
            [ LID_PATTERN_RADIUS, 3 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
        ],
    ],
];
Make(data);
