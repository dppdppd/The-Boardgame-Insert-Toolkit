// Test: FEATURE_COPY repeats a named FEATURE_GROUP with child layout intact.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "copied resource clusters" ],
        [ BOX_SIZE_XYZ, [144, 70, 24] ],
        [ BOX_NO_LID_B, true ],

        [ FEATURE_GROUP,
            [ NAME, "resource cluster prototype" ],
            [ POSITION_XY, [14, 18] ],

            [ BOX_FEATURE,
                [ NAME, "coin well in cluster" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [18, 18, 18] ],
                [ FTR_SHAPE, ROUND ],
                [ FTR_SHAPE_VERTICAL_B, true ],
                [ POSITION_XY, [0, 0] ],
            ],

            [ BOX_FEATURE,
                [ NAME, "card well in cluster" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [24, 18, 18] ],
                [ POSITION_XY, [26, 0] ],
            ],
        ],

        [ FEATURE_COPY,
            [ NAME, "second resource cluster" ],
            [ FEATURE_REFERENCE, "resource cluster prototype" ],
            [ POSITION_XY, [76, 18] ],
            [ ROTATION, 10 ],
        ],
    ],
];

Make(data);
