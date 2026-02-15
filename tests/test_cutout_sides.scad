// Test: Side cutouts — CMP_CUTOUT_SIDES_4B with various combinations
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "front-back cutouts",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
                    [ CMP_CUTOUT_SIDES_4B, [t, t, f, f] ],
                ]
            ]
        ]
    ],
    [ "all sides cutout",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
                    [ CMP_CUTOUT_SIDES_4B, [t, t, t, t] ],
                ]
            ]
        ]
    ],
    [ "left only cutout",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
                    [ CMP_CUTOUT_SIDES_4B, [f, f, f, t] ],
                ]
            ]
        ]
    ],
];

MakeAll();
