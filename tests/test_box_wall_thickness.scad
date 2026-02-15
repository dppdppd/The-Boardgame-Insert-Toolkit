// Test: Different wall thickness values
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";
g_wall_thickness = 3.0;

data = [
    [ "thick walls",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [40, 40, 16] ],
                ]
            ]
        ]
    ],
];

MakeAll();
