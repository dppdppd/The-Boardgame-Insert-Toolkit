// Test: Custom lid height — LID_HEIGHT
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "tall lid" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID,
            [ LID_HEIGHT, 15 ],
            [ LID_PATTERN_RADIUS, 8 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "short lid" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID,
            [ LID_HEIGHT, 3 ],
            [ LID_SOLID_B, t ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ],
    ],
];
Make(data);
