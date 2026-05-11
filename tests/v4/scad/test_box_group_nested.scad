// Test: BOX_GROUP can live inside a physical parent feature to transform
// multiple nested child wells together.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "nested group in parent tray" ],
        [ BOX_SIZE_XYZ, [104, 72, 26] ],
        [ BOX_NO_LID_B, true ],

        [ BOX_FEATURE,
            [ NAME, "player tray" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [88, 56, 12] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_GROUP,
                [ NAME, "grouped status wells" ],
                [ POSITION_XY, [20, 16] ],
                [ ROTATION, -10 ],

                [ BOX_FEATURE,
                    [ NAME, "health token bay" ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 22] ],
                    [ FTR_SHAPE, ROUND ],
                    [ FTR_SHAPE_VERTICAL_B, true ],
                    [ POSITION_XY, [0, 0] ],
                ],

                [ BOX_FEATURE,
                    [ NAME, "shield token bay" ],
                    [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 22] ],
                    [ FTR_SHAPE, ROUND ],
                    [ FTR_SHAPE_VERTICAL_B, true ],
                    [ POSITION_XY, [26, 0] ],
                ],
            ],
        ],
    ],
];

Make(data);
