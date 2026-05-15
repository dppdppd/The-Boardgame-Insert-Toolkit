// Test: Inset lid — LID_INSET_B with stackable box
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, LID, DIVIDERS ] ],
    [ OBJECT_BOX,
        [ NAME, "inset lid stackable" ],
        [ BOX_SIZE_XYZ, [45, 45, 15] ],
        [ BOX_STACKABLE_B, t ],
        [ BOX_LID,
            [ LID_SOLID_B, t ],
            [ LID_INSET_B, t ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [42, 42, 13] ],
        ],
    ],
];
Make(data);
