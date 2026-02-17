// Test: Solid lid — LID_SOLID_B
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "solid lid",
        [
            [ BOX_SIZE_XYZ, [45, 45, 15] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t ],
                ]
            ],
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [42, 42, 13] ],
                ]
            ],
        ]
    ],
];

MakeAll();
