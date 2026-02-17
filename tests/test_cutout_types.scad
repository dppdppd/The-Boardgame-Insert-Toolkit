// Test: Cutout types — INTERIOR, EXTERIOR, BOTH
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "interior cutout",
        [
            [ BOX_SIZE_XYZ, [58, 58, 10] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ FTR_SHAPE, HEX ],
                    [ FTR_SHAPE_VERTICAL_B, t ],
                    [ FTR_CUTOUT_TYPE, INTERIOR ],
                    [ FTR_CUTOUT_SIDES_4B, [f, f, t, t] ],
                ]
            ]
        ]
    ],
    [ "exterior cutout",
        [
            [ BOX_SIZE_XYZ, [58, 58, 10] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ FTR_SHAPE, HEX ],
                    [ FTR_SHAPE_VERTICAL_B, t ],
                    [ FTR_CUTOUT_TYPE, EXTERIOR ],
                    [ FTR_CUTOUT_SIDES_4B, [f, f, t, t] ],
                ]
            ]
        ]
    ],
    [ "both cutout",
        [
            [ BOX_SIZE_XYZ, [58, 58, 10] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ FTR_SHAPE, HEX ],
                    [ FTR_SHAPE_VERTICAL_B, t ],
                    [ FTR_CUTOUT_TYPE, BOTH ],
                    [ FTR_CUTOUT_SIDES_4B, [f, f, t, t] ],
                ]
            ]
        ]
    ],
];

MakeAll();
