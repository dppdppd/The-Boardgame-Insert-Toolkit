// Test: Lid stripes — LID_STRIPE_WIDTH and LID_STRIPE_SPACE
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "striped lid",
        [
            [ BOX_SIZE_XYZ, [60, 60, 15] ],
            [ BOX_LID,
                [
                    [ LID_STRIPE_WIDTH, 2 ],
                    [ LID_STRIPE_SPACE, 3 ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
                ]
            ],
        ]
    ],
    [ "wide stripes",
        [
            [ BOX_SIZE_XYZ, [60, 60, 15] ],
            [ BOX_LID,
                [
                    [ LID_STRIPE_WIDTH, 5 ],
                    [ LID_STRIPE_SPACE, 2 ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
                ]
            ],
        ]
    ],
];

MakeAll();
