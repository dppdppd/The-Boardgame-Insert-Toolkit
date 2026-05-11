// Practical nested geometry example:
// A shallow player-dashboard tray has deeper scoring/resource wells cut into
// the tray floor. The nested children also carry labels and finger cutouts.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "player dashboard with nested wells" ],
        [ BOX_SIZE_XYZ, [104, 70, 26] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "player dashboard cavity" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [88, 54, 12] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "victory point marker well" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [30, 34, 22] ],
                [ POSITION_XY, [8, CENTER] ],
                [ LABEL,
                    [ LBL_TEXT, "VP" ],
                    [ LBL_PLACEMENT, CENTER ],
                    [ LBL_SIZE, 12 ],
                    [ LBL_DEPTH, 20 ],
                ],
            ],

            [ BOX_FEATURE,
                [ NAME, "resource grab well" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [30, 34, 22] ],
                [ POSITION_XY, [50, CENTER] ],
                [ FTR_CUTOUT_SIDES_4B, [t, f, f, t] ],
                [ FTR_CUTOUT_CORNERS_4B, [f, t, f, f] ],
                [ FTR_CUTOUT_BOTTOM_B, t ],
                [ FTR_CUTOUT_BOTTOM_PCT, 45 ],
                [ FTR_CUTOUT_WIDTH_PCT, 55 ],
                [ FTR_CUTOUT_DEPTH_PCT, 35 ],
            ],
        ],
    ],
];

Make(data);
