// Test: SQUARE compartment shape (default)
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "square default",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_SHAPE, SQUARE ],
                ]
            ]
        ]
    ],
];

MakeAll();
