// Test: Integration — card tray with shear, cutouts, padding, lid with label
// NOTE: Simplified from original (2x2 instead of 2x4, smaller lid pattern)
//       to keep render time under 2 minutes.
include <../boardgame_insert_toolkit_lib.4.scad>;
include <../bit_functions_lib.4.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "card tray combo",
        [
            [ BOX_SIZE_XYZ, [100, 60, cos(20)*50 - 8] ],
            [ BOX_LID,
                [
                    [ LID_PATTERN_RADIUS, 10 ],
                    [ LID_PATTERN_THICKNESS, 0.6 ],
                    [ LID_PATTERN_N1, 6 ],
                    [ LID_PATTERN_N2, 6 ],
                ],
            ],
            [ BOX_FEATURE,
                [
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [45, 15, 35] ],
                    [ FTR_SHEAR, [0, 30] ],
                    [ FTR_PADDING_XY, [1, 6] ],
                    [ FTR_PADDING_HEIGHT_ADJUST_XY, [-15, -15] ],
                    [ FTR_MARGIN_FBLR, [30, 0, 0, 0] ],
                    [ POSITION_XY, [CENTER, -20] ],
                    [ FTR_CUTOUT_SIDES_4B, [t, t, f, f] ],
                    [ FTR_CUTOUT_DEPTH_PCT, 30 ],
                    [ FTR_CUTOUT_WIDTH_PCT, 50 ],
                    [ FTR_CUTOUT_HEIGHT_PCT, 100 ],
                ]
            ],
        ]
    ],
];

MakeAll();
