// Test: Positioning — CENTER and explicit XY positions
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "centered component",
        [
            [ BOX_SIZE_XYZ, [80, 80, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [30, 30, 18] ],
                    [ POSITION_XY, [CENTER, CENTER] ],
                ]
            ],
        ]
    ],
    [ "explicit positioned",
        [
            [ BOX_SIZE_XYZ, [80, 80, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ POSITION_XY, [5, 5] ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ POSITION_XY, [50, 50] ],
                ]
            ],
        ]
    ],
];

MakeAll();
