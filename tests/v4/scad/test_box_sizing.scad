// Test: Various box sizes — small, medium, large, and non-square aspect ratios
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "tiny box" ],
        [ BOX_SIZE_XYZ, [20, 20, 10] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [16, 16, 8] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "wide flat box" ],
        [ BOX_SIZE_XYZ, [120, 40, 10] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [116, 36, 8] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "tall narrow box" ],
        [ BOX_SIZE_XYZ, [30, 30, 50] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [26, 26, 48] ],
        ],
    ],
];
Make(data);
