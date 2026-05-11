// Use-case:
// A shallow card tray has a 3x2 set of round token bays nested into its floor.
// The token bays are deeper than the parent tray, so their openings are flush
// with the card-tray floor instead of rising into the card space.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "card tray over round token bays" ],
        [ BOX_SIZE_XYZ, [120, 86, 28] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "shallow card tray" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [104, 70, 12] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "3x2 token bays below tray floor" ],
                [ FTR_NUM_COMPARTMENTS_XY, [3, 2] ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 24] ],
                [ FTR_PADDING_XY, [5, 5] ],
                [ FTR_SHAPE, ROUND ],
                [ FTR_SHAPE_VERTICAL_B, true ],
                [ POSITION_XY, [CENTER, CENTER] ],
            ],
        ],
    ],
];

Make(data);
