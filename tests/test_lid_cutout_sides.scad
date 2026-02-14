// Test: Lid cutout sides — LID_CUTOUT_SIDES_4B
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "lid cutouts front-back",
        [
            [ BOX_SIZE_XYZ, [60, 60, 20] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t ],
                    [ LID_CUTOUT_SIDES_4B, [t, t, f, f] ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
                ]
            ],
        ]
    ],
];

MakeAll();
