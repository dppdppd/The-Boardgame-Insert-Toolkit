// Test: Compartment shear — FTR_SHEAR [x_angle, y_angle]
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "y-shear 45" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 4] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 5, 4] ],
            [ FTR_SHEAR, [0, 45] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "x-shear 30" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [4, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [5, 20, 4] ],
            [ FTR_SHEAR, [30, 0] ],
        ],
    ],
];
Make(data);
