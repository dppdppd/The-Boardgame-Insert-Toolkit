// Test: Cutout types — INTERIOR, EXTERIOR, BOTH
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "interior cutout",
        [
            [ BOX_SIZE_XYZ, [58, 58, 10] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ CMP_SHAPE, HEX ],
                    [ CMP_SHAPE_VERTICAL_B, t ],
                    [ CMP_CUTOUT_TYPE, INTERIOR ],
                    [ CMP_CUTOUT_SIDES_4B, [f, f, t, t] ],
                ]
            ]
        ]
    ],
    [ "exterior cutout",
        [
            [ BOX_SIZE_XYZ, [58, 58, 10] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ CMP_SHAPE, HEX ],
                    [ CMP_SHAPE_VERTICAL_B, t ],
                    [ CMP_CUTOUT_TYPE, EXTERIOR ],
                    [ CMP_CUTOUT_SIDES_4B, [f, f, t, t] ],
                ]
            ]
        ]
    ],
    [ "both cutout",
        [
            [ BOX_SIZE_XYZ, [58, 58, 10] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ CMP_SHAPE, HEX ],
                    [ CMP_SHAPE_VERTICAL_B, t ],
                    [ CMP_CUTOUT_TYPE, BOTH ],
                    [ CMP_CUTOUT_SIDES_4B, [f, f, t, t] ],
                ]
            ]
        ]
    ],
];

MakeAll();
