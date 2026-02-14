// Test: Lid labels — text on lid with positioning and rotation
include <../boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "lid labels",
        [
            [ BOX_SIZE_XYZ, [60, 60, 15] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 8 ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, "GAME" ],
                            [ LBL_SIZE, AUTO ],
                        ]
                    ],
                ],
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
                ]
            ],
        ]
    ],
    [ "lid label rotated",
        [
            [ BOX_SIZE_XYZ, [60, 60, 15] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 8 ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, "ANGLED" ],
                            [ LBL_SIZE, AUTO ],
                            [ ROTATION, 45 ],
                            [ POSITION_XY, [2, -2] ],
                        ]
                    ],
                ],
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
