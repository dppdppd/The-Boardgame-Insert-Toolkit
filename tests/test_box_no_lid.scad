// Test: Box with BOX_NO_LID_B explicitly set
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "no lid box",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_NO_LID_B, t ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
                ]
            ]
        ]
    ],
];

MakeAll();
