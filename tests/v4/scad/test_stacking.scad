// Test: Stackable boxes — BOX_STACKABLE_B
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, LID, DIVIDERS ] ],
    [ OBJECT_BOX,
        [ NAME, "stackable box" ],
        [ BOX_SIZE_XYZ, [50, 50, 15] ],
        [ BOX_STACKABLE_B, t ],
        [ BOX_LID,
            [ LID_SOLID_B, t ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 13] ],
        ],
    ],
];
Make(data);
