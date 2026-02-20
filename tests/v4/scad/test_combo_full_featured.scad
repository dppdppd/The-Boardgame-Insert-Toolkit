// BITGUI
include <boardgame_insert_toolkit_lib.4.scad>;
// Test: Integration — full-featured box with lid labels, component labels, pattern, cutouts
data = [
    [ OBJECT_BOX,
        [ NAME, "full featured box" ],
        [ BOX_SIZE_XYZ, [70, 90, 22] ],
        [ BOX_LID,
            [ LID_SOLID_B, f ],
            [ LID_FIT_UNDER_B, f ],
            [ LID_PATTERN_RADIUS, 8 ],
            [ LID_HEIGHT, 10 ],
            [ LABEL,
                [ LBL_TEXT, "GAME" ],
                [ LBL_SIZE, AUTO ],
                [ ROTATION, 45 ],
                [ POSITION_XY, [2, -2] ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [22, 30, 20] ],
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_SHAPE, SQUARE ],
            [ FTR_PADDING_XY, [5, 5] ],
            [ FTR_PADDING_HEIGHT_ADJUST_XY, [-5, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [f, f, f, t] ],
            [ ROTATION, 5 ],
            [ POSITION_XY, [CENTER, CENTER] ],
            [ LABEL,
                [ LBL_TEXT,
                    [
                        [ "BL", "BR" ],
                        [ "FL", "FR" ],
                    ]
                ],
                [ LBL_PLACEMENT, FRONT ],
                [ LBL_SIZE, AUTO ],
            ],
        ],
    ],
];
Make(data);