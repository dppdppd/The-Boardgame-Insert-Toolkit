// Test: Absolute minimal box — just BOX_SIZE_XYZ and one compartment
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "minimal",
        [
            [ BOX_SIZE_XYZ, [46.5, 46.5, 15.0] ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [4, 4] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [ 10, 10, 13.0] ],
                ]
            ]
        ]
    ],
];

MakeAll();
