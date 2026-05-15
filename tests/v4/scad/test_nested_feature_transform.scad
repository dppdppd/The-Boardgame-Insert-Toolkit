// Practical nested geometry example:
// A shallow diagonal market-row tray has deeper bonus-tile wells cut into its
// floor, with the nested child rotated relative to the parent tray.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, DIVIDERS ] ],

    [ OBJECT_BOX,
        [ NAME, "diagonal market tray with bonus wells" ],
        [ BOX_SIZE_XYZ, [120, 92, 28] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "angled market card row" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [88, 56, 12] ],
            [ POSITION_XY, [CENTER, CENTER] ],
            [ ROTATION, 12 ],

            [ BOX_FEATURE,
                [ NAME, "deeper rotated bonus-tile wells" ],
                [ FTR_NUM_COMPARTMENTS_XY, [2, 1] ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [16, 12, 24] ],
                [ FTR_PADDING_XY, [5, 1] ],
                [ POSITION_XY, [CENTER, MAX] ],
                [ ROTATION, -35 ],
            ],
        ],
    ],
];

Make(data);
