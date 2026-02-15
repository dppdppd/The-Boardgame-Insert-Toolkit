// Test: Inset lid — LID_INSET_B with stackable box
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "inset lid stackable",
        [
            [ BOX_SIZE_XYZ, [45, 45, 15] ],
            [ BOX_STACKABLE_B, t ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, t ],
                    [ LID_INSET_B, t ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [42, 42, 13] ],
                ]
            ],
        ]
    ],
];

MakeAll();
