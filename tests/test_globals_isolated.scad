// Test: g_isolated_print_box — only render the named box
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "target box";

data = [
    [ "hidden box",
        [
            [ BOX_SIZE_XYZ, [40, 40, 15] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [36, 36, 13] ],
                ]
            ]
        ]
    ],
    [ "target box",
        [
            [ BOX_SIZE_XYZ, [60, 60, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [3, 3] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [16, 16, 18] ],
                ]
            ]
        ]
    ],
];

MakeAll();
