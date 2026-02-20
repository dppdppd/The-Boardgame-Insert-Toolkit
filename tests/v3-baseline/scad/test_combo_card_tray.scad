// Test: Integration — card tray with shear, cutouts, padding, lid with label
include <boardgame_insert_toolkit_lib.3.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "card tray combo",
        [
            [ BOX_SIZE_XYZ, [138, 87, cos(20)*50 - 8] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 10 ],
                    [ LID_PATTERN_THICKNESS, 1.5 ],
                    [ LABEL,
                        [
                            [ LBL_TEXT, "STOCK" ],
                            [ LBL_SIZE, AUTO ],
                        ]
                    ],
                    [ LID_PATTERN_N1, 10 ],
                    [ LID_PATTERN_N2, 10 ],
                    [ LID_PATTERN_ANGLE, 60 ],
                    [ LID_PATTERN_ROW_OFFSET, 10 ],
                    [ LID_PATTERN_COL_OFFSET, 140 ],
                    [ LID_PATTERN_THICKNESS, 0.6 ],
                ],
            ],
            [ BOX_COMPONENT,
                [
                    [ CMP_NUM_COMPARTMENTS_XY, [2, 4] ],
                    [ CMP_COMPARTMENT_SIZE_XYZ, [66, 10, 44] ],
                    [ CMP_SHEAR, [0, 40] ],
                    [ CMP_PADDING_XY, [1, 6] ],
                    [ CMP_PADDING_HEIGHT_ADJUST_XY, [-20, -20] ],
                    [ CMP_MARGIN_FBLR, [40, 0, 0, 0] ],
                    [ POSITION_XY, [CENTER, -25] ],
                    [ CMP_CUTOUT_SIDES_4B, [t, t, f, f] ],
                    [ CMP_CUTOUT_DEPTH_PCT, 30 ],
                    [ CMP_CUTOUT_WIDTH_PCT, 50 ],
                    [ CMP_CUTOUT_HEIGHT_PCT, 100 ],
                ]
            ],
        ]
    ],
];

MakeAll();
