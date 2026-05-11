// Test: BOX_GROUP moves and rotates adjacent sibling features together without
// creating parent geometry.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "box group adjacent wells" ],
        [ BOX_SIZE_XYZ, [92, 62, 24] ],
        [ BOX_NO_LID_B, true ],

        [ BOX_GROUP,
            [ NAME, "rotated player resource pair" ],
            [ POSITION_XY, [18, 16] ],
            [ ROTATION, 12 ],

            [ BOX_FEATURE,
                [ NAME, "coin well" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 18] ],
                [ FTR_SHAPE, ROUND ],
                [ FTR_SHAPE_VERTICAL_B, true ],
                [ POSITION_XY, [0, 0] ],
            ],

            [ BOX_FEATURE,
                [ NAME, "damage well" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 18] ],
                [ POSITION_XY, [28, 0] ],
            ],
        ],
    ],
];

Make(data);
