// Test: Compartment margins — CMP_MARGIN_FBLR [front, back, left, right]
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "uniform margin",
        [
            [ BOX_SIZE_XYZ, [60, 60, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [30, 30, 18] ],
                    [ CMP_MARGIN_FBLR, [10, 10, 10, 10] ],
                ]
            ]
        ]
    ],
    [ "front-heavy margin",
        [
            [ BOX_SIZE_XYZ, [60, 80, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [50, 30, 18] ],
                    [ CMP_MARGIN_FBLR, [30, 0, 0, 0] ],
                ]
            ]
        ]
    ],
];

MakeAll();
