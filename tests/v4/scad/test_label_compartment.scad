// Test: Compartment labels — per-compartment text arrays, BACK and BACK_WALL placements
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "compartment labels" ],
        [ BOX_SIZE_XYZ, [60, 60, 15] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 5] ],
            [ FTR_PADDING_XY, [5, 5] ],
            [ LABEL,
                [ LBL_TEXT,
                    [
                        [ "BL", "BR" ],
                        [ "FL", "FR" ],
                    ]
                ],
                [ LBL_PLACEMENT, BACK ],
                [ LBL_SIZE, AUTO ],
            ],
            [ LABEL,
                [ LBL_TEXT,
                    [
                        [ "1", "2" ],
                        [ "3", "4" ],
                    ]
                ],
                [ LBL_PLACEMENT, BACK_WALL ],
                [ LBL_SIZE, AUTO ],
            ],
        ],
    ],
];
Make(data);
