// Test: nested BOX_FEATURE child renders local geometry inside a parent feature.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "nested feature basic" ],
        [ BOX_SIZE_XYZ, [80, 60, 22] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ NAME, "parent square cavity" ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [68, 48, 18] ],
            [ POSITION_XY, [CENTER, CENTER] ],

            [ BOX_FEATURE,
                [ NAME, "child round well" ],
                [ FTR_COMPARTMENT_SIZE_XYZ, [22, 22, 12] ],
                [ FTR_SHAPE, ROUND ],
                [ FTR_SHAPE_VERTICAL_B, true ],
                [ POSITION_XY, [CENTER, MAX] ],
            ],
        ],
    ],
];

Make(data);
