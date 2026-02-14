// Test: OCT2 compartment shape (rotated octagon) — normal, rotated, vertical
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "oct2 normal",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_SHAPE, OCT2 ],
                ]
            ]
        ]
    ],
    [ "oct2 rotated",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_SHAPE, OCT2 ],
                    [ CMP_SHAPE_ROTATED_B, t ],
                ]
            ]
        ]
    ],
    [ "oct2 vertical",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ CMP_SHAPE, OCT2 ],
                    [ CMP_SHAPE_VERTICAL_B, t ],
                ]
            ]
        ]
    ],
];

MakeAll();
