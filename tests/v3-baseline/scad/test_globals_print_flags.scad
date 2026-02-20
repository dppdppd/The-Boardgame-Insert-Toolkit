// Test: g_b_print_lid=true, g_b_print_box=false — should only render the lid
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = false;
g_isolated_print_box = "";

data = [
    [ "lid only",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 8 ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
                ]
            ],
        ]
    ],
];

MakeAll();
