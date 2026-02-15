// Test: Compartment shear — CMP_SHEAR [x_angle, y_angle]
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "y-shear 45",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 4] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 5, 4] ],
                    [ CMP_SHEAR, [0, 45] ],
                ]
            ]
        ]
    ],
    [ "x-shear 30",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [4, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [5, 20, 4] ],
                    [ CMP_SHEAR, [30, 0] ],
                ]
            ]
        ]
    ],
];

MakeAll();
