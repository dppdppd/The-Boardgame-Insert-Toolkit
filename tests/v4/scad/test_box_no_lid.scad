// Test: Box with BOX_NO_LID_B explicitly set
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "no lid box" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_NO_LID_B, t ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
        ],
    ],
];
Make(data);
