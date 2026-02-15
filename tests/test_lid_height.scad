// Test: Custom lid height — LID_HEIGHT
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "tall lid",
        [
            [ BOX_SIZE_XYZ, [60, 60, 20] ],
            [ BOX_LID,
                [
                    [ LID_HEIGHT, 15 ],
                    [ LID_PATTERN_RADIUS, 8 ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
                ]
            ],
        ]
    ],
    [ "short lid",
        [
            [ BOX_SIZE_XYZ, [60, 60, 20] ],
            [ BOX_LID,
                [
                    [ LID_HEIGHT, 3 ],
                    [ LID_SOLID_B, t ],
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
