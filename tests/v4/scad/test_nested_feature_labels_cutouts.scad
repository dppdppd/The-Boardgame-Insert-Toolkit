// Test: nested BOX_FEATURE child labels and cutouts use the child frame.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "nested child labels and cutouts" ],
        [ BOX_SIZE_XYZ, [104, 70, 26] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "parent display cavity" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [88, 54, 22] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "labeled child well" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [30, 34, 14] ],
                [ POSITION_XY, [8, CENTER] ],
                [ LABEL,
                    [ LBL_TEXT, "X" ],
                    [ LBL_PLACEMENT, CENTER ],
                    [ LBL_SIZE, 16 ],
                    [ LBL_DEPTH, 20 ],
                ],
            ],

            [ BOX_FEATURE,
                [ NAME, "cutout child well" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [30, 34, 14] ],
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
