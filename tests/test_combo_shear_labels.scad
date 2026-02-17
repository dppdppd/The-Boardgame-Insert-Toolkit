// Test: Integration — sheared compartments with per-compartment wall labels
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "shear with labels",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t ],
                ]
            ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 4] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [20, 5, 4] ],
                    [ FTR_SHEAR, [0, 45] ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, [
                                ["1", "2"],
                                ["3", "4"],
                                ["5", "6"],
                                ["7", "8"],
                            ]],
                            [ LBL_PLACEMENT, BACK_WALL ],
                            [ LBL_SIZE, 2 ],
                        ]
                    ],
                ]
            ],
        ]
    ],
];

MakeAll();
