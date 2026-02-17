// Test: FILLET compartment shape — normal, rotated, with custom fillet radius
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "fillet normal",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ FTR_SHAPE, FILLET ],
                ]
            ]
        ]
    ],
    [ "fillet rotated",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ FTR_SHAPE, FILLET ],
                    [ FTR_SHAPE_ROTATED_B, t ],
                ]
            ]
        ]
    ],
    [ "fillet custom radius",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
                    [ FTR_SHAPE, FILLET ],
                    [ FTR_FILLET_RADIUS, 8 ],
                ]
            ]
        ]
    ],
];

MakeAll();
