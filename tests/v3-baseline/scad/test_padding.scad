// Test: Compartment padding — CMP_PADDING_XY and CMP_PADDING_HEIGHT_ADJUST_XY
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "large padding",
        [
            [ BOX_SIZE_XYZ, [80, 80, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_PADDING_XY, [10, 10] ],
                ]
            ]
        ]
    ],
    [ "asymmetric padding",
        [
            [ BOX_SIZE_XYZ, [80, 80, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_PADDING_XY, [15, 5] ],
                ]
            ]
        ]
    ],
    [ "padding height adjust",
        [
            [ BOX_SIZE_XYZ, [80, 80, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_PADDING_XY, [10, 10] ],
                    [ CMP_PADDING_HEIGHT_ADJUST_XY, [-5, -10] ],
                ]
            ]
        ]
    ],
];

MakeAll();
