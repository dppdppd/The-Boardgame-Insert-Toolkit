// Test: Box with BOX_NO_LID_B explicitly set
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, LID, DIVIDERS ] ],
    [ OBJECT_BOX,
        [ NAME, "no lid box" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_NO_LID_B, t ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
        ],
    ],
];
Make(data);
