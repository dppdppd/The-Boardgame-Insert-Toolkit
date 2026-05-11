// Test: FEATURE_COPY repeats a nested child feature inside a physical parent tray.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "nested copied wells" ],
        [ BOX_SIZE_XYZ, [98, 62, 26] ],
        [ BOX_NO_LID_B, true ],

        [ BOX_FEATURE,
            [ NAME, "player tray with copied token wells" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [82, 46, 12] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "health token bay prototype" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 22] ],
                [ FTR_SHAPE, ROUND ],
                [ FTR_SHAPE_VERTICAL_B, true ],
                [ POSITION_XY, [18, 14] ],
            ],

            [ FEATURE_COPY,
                [ NAME, "second health token bay" ],
                [ FEATURE_REFERENCE, "health token bay prototype" ],
                [ POSITION_XY, [46, 14] ],
            ],
        ],
    ],
];

Make(data);
