// Test: Various box sizes — small, medium, large, and non-square aspect ratios
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "tiny box",
        [
            [ BOX_SIZE_XYZ, [20, 20, 10] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [16, 16, 8] ],
                ]
            ]
        ]
    ],
    [ "wide flat box",
        [
            [ BOX_SIZE_XYZ, [120, 40, 10] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [116, 36, 8] ],
                ]
            ]
        ]
    ],
    [ "tall narrow box",
        [
            [ BOX_SIZE_XYZ, [30, 30, 50] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [26, 26, 48] ],
                ]
            ]
        ]
    ],
];

MakeAll();
