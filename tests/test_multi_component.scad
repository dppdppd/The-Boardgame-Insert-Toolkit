// Test: Multiple BOX_COMPONENTs in a single box — different shapes and positions
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "multi component",
        [
            [ BOX_SIZE_XYZ, [100, 80, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [40, 70, 18] ],
                    [ POSITION_XY, [3, 3] ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 3] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_SHAPE, ROUND ],
                    [ POSITION_XY, [50, 3] ],
                ]
            ],
        ]
    ],
];

MakeAll();
