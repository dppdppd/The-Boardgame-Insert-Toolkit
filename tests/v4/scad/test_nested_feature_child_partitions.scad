// Test: nested BOX_FEATURE child grid preserves floors and partitions.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "nested child partitions" ],
        [ BOX_SIZE_XYZ, [90, 70, 24] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "parent deep cavity" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [74, 54, 20] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "child 2x2 tray" ],
                [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [14, 12, 12] ],
                [ FTR_PADDING_XY, [2, 2] ],
                [ POSITION_XY, [CENTER, CENTER] ],
            ],
        ],
    ],
];

Make(data);
