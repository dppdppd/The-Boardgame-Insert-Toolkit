// Test: Integration — sheared compartments with per-compartment wall labels
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "shear with labels" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_LID,
            [ LID_SOLID_B, t ],
        ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 4] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 5, 4] ],
            [ FTR_SHEAR, [0, 45] ],
            [ LABEL,
                [ LBL_TEXT,
                    [
                        [ "1", "2" ],
                        [ "3", "4" ],
                        [ "5", "6" ],
                        [ "7", "8" ],
                    ]
                ],
                [ LBL_PLACEMENT, BACK_WALL ],
                [ LBL_SIZE, 2 ],
            ],
        ],
    ],
];
Make(data);
