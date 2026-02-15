// Test: Corner cutouts — CMP_CUTOUT_CORNERS_4B
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "all corner cutouts",
        [
            [ BOX_SIZE_XYZ, [55, 55, 10] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ CMP_SHAPE, HEX2 ],
                    [ CMP_SHAPE_VERTICAL_B, t ],
                    [ CMP_CUTOUT_CORNERS_4B, [t, t, t, t] ],
                ]
            ]
        ]
    ],
    [ "diagonal corner cutouts",
        [
            [ BOX_SIZE_XYZ, [55, 55, 10] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
                    [ CMP_SHAPE, HEX2 ],
                    [ CMP_SHAPE_VERTICAL_B, t ],
                    [ CMP_CUTOUT_CORNERS_4B, [t, f, t, f] ],
                ]
            ]
        ]
    ],
];

MakeAll();
