// Test: FEATURE_COPY repeats a named feature at its own position.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, DIVIDERS ] ],

    [ OBJECT_BOX,
        [ NAME, "copied single token bays" ],
        [ BOX_SIZE_XYZ, [104, 54, 24] ],
        [ BOX_NO_LID_B, true ],

        [ BOX_FEATURE,
            [ NAME, "round token bay prototype" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ FTR_SHAPE, ROUND ],
            [ FTR_SHAPE_VERTICAL_B, true ],
            [ POSITION_XY, [14, 16] ],
        ],

        [ FEATURE_COPY,
            [ NAME, "second token bay" ],
            [ FEATURE_REFERENCE, "round token bay prototype" ],
            [ POSITION_XY, [44, 16] ],
        ],

        [ FEATURE_COPY,
            [ NAME, "rotated third token bay" ],
            [ FEATURE_REFERENCE, "round token bay prototype" ],
            [ POSITION_XY, [74, 16] ],
            [ ROTATION, 20 ],
        ],
    ],
];

Make(data);
