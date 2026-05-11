// Test: nested BOX_FEATURE child composes parent rotation, CENTER/MAX placement,
// and child rotation in the parent feature's local frame.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "nested child transform" ],
        [ BOX_SIZE_XYZ, [112, 86, 26] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "rotated parent cavity" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [78, 54, 21] ],
            [ POSITION_XY, [CENTER, CENTER] ],
            [ ROTATION, 12 ],

            [ BOX_FEATURE,
                [ NAME, "rotated child max edge tray" ],
                [ FTR_NUM_COMPARTMENTS_XY, [2, 1] ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [15, 11, 12] ],
                [ FTR_PADDING_XY, [6, 1] ],
                [ POSITION_XY, [CENTER, MAX] ],
                [ ROTATION, -42 ],
            ],
        ],
    ],
];

Make(data);
