// Test: over-height ROUND feature remains a cavity.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, BOX ],
    [ G_PRINT_GROUPS, [ "shell", "insert" ] ],
    [ OBJECT_BOX,
        [ NAME, "round full height cavity" ],
        [ PRINT_GROUP, "shell" ],
        [ BOX_SIZE_XYZ, [110, 100, 42] ],
        [ BOX_NO_LID_B, true ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [73, 96, 34] ],
            [ POSITION_XY, [0, 0] ],
            [ FTR_CUTOUT_SIDES_4B, [true, true, false, false] ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
        ],
        [ BOX_FEATURE,
            [ PRINT_GROUP, "insert" ],
            [ FTR_SHAPE, ROUND ],
            [ FTR_SHAPE_VERTICAL_B, true ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 43] ],
            [ POSITION_XY, [MAX, CENTER] ],
        ],
    ],
];
Make(data);
