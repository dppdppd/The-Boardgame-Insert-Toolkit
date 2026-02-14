// Test: Bottom cutouts — CMP_CUTOUT_BOTTOM_B and CMP_CUTOUT_BOTTOM_PCT
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "bottom cutout",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
                    [ CMP_CUTOUT_BOTTOM_B, t ],
                ]
            ]
        ]
    ],
    [ "bottom cutout 50pct",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
                    [ CMP_CUTOUT_BOTTOM_B, t ],
                    [ CMP_CUTOUT_BOTTOM_PCT, 50 ],
                ]
            ]
        ]
    ],
];

MakeAll();
