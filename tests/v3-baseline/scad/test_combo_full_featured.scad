// Test: Integration — full-featured box with lid labels, component labels, pattern, cutouts
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "full featured box",
        [
            [ BOX_SIZE_XYZ, [70, 90, 22] ],
            [ BOX_LID,
                [
                    [ LID_SOLID_B, f ],
                    [ LID_FIT_UNDER_B, f ],
                    [ LID_PATTERN_RADIUS, 8 ],
                    [ LID_HEIGHT, 10 ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, "GAME" ],
                            [ LBL_SIZE, AUTO ],
                            [ ROTATION, 45 ],
                            [ POSITION_XY, [2, -2] ],
                        ]
                    ],
                ],
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [22, 30, 20] ],
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ CMP_SHAPE, SQUARE ],
                    [ CMP_PADDING_XY, [5, 5] ],
                    [ CMP_PADDING_HEIGHT_ADJUST_XY, [-5, 0] ],
                    [ CMP_CUTOUT_SIDES_4B, [f, f, f, t] ],
                    [ ROTATION, 5 ],
                    [ POSITION_XY, [CENTER, CENTER] ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, [
                                ["BL", "BR"],
                                ["FL", "FR"],
                            ]],
                            [ LBL_PLACEMENT, FRONT ],
                            [ LBL_SIZE, AUTO ],
                        ]
                    ],
                ]
            ],
        ]
    ],
];

MakeAll();
