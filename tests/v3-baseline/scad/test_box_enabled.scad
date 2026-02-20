// Test: ENABLED_B flag — one enabled, one disabled, should only render the enabled one
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "enabled box",
        [
            [ ENABLED_B, t ],
            [ BOX_SIZE_XYZ, [40, 40, 15] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [36, 36, 13] ],
                ]
            ]
        ]
    ],
    [ "disabled box",
        [
            [ ENABLED_B, f ],
            [ BOX_SIZE_XYZ, [40, 40, 15] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [36, 36, 13] ],
                ]
            ]
        ]
    ],
];

MakeAll();
