// Use-case:
// A shallow card tray has a deeper round token bay in the tray floor. The child
// cavity is deeper than the parent tray so its opening is flush with the tray
// floor instead of protruding into the card space.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "card tray with token bay in floor" ],
        [ BOX_SIZE_XYZ, [96, 70, 26] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "shallow card tray" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [82, 56, 12] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "round token bay below tray floor" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 22] ],
                [ FTR_SHAPE, ROUND ],
                [ FTR_SHAPE_VERTICAL_B, true ],
                [ POSITION_XY, [CENTER, 12] ],
            ],
        ],
    ],
];

Make(data);
