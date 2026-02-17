// Test: ROUND compartment shape — normal, rotated, and vertical
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "round normal",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ FTR_SHAPE, ROUND ],
                ]
            ]
        ]
    ],
    [ "round rotated",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ FTR_SHAPE, ROUND ],
                    [ FTR_SHAPE_ROTATED_B, t ],
                ]
            ]
        ]
    ],
    [ "round vertical",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ FTR_SHAPE, ROUND ],
                    [ FTR_SHAPE_VERTICAL_B, t ],
                ]
            ]
        ]
    ],
];

MakeAll();
