// Test: Pattern lid — default hex pattern with various radius values
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "default pattern lid",
        [
            [ BOX_SIZE_XYZ, [60, 60, 15] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 8 ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
                ]
            ],
        ]
    ],
    [ "small pattern",
        [
            [ BOX_SIZE_XYZ, [60, 60, 15] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 3 ],
                ]
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
                ]
            ],
        ]
    ],
];

MakeAll();
