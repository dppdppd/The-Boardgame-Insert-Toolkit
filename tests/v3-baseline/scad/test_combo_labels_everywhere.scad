// Test: Integration — labels on lid, all box sides, and per-compartment
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "labels everywhere",
        [
            [ BOX_SIZE_XYZ, [60, 60, 20] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 8 ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, "TOP LABEL" ],
                            [ LBL_SIZE, AUTO ],
                        ]
                    ],
                ],
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "FRONT" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, FRONT ],
                ]
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "BACK" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, BACK ],
                ]
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "LEFT" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, LEFT ],
                ]
            ],
            [ LABEL,
                [
                    [ LBL_TEXT, "RIGHT" ],
                    [ LBL_SIZE, AUTO ],
                    [ LBL_PLACEMENT, RIGHT ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 5] ],
                    [ CMP_PADDING_XY, [5, 5] ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, [
                                ["A", "B"],
                                ["C", "D"],
                            ]],
                            [ LBL_PLACEMENT, BACK ],
                            [ LBL_SIZE, AUTO ],
                        ]
                    ],
                ]
            ],
        ]
    ],
];

MakeAll();
