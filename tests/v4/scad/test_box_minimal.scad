// Test: Absolute minimal box — just BOX_SIZE_XYZ and one compartment
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "minimal" ],
        [ BOX_SIZE_XYZ, [46.5, 46.5, 15.0] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [4, 4] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [10, 10, 13.0] ],
        ],
    ],
];
Make(data);
