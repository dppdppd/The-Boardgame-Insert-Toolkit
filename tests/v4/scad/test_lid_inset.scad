// Test: Inset lid — LID_INSET_B with stackable box
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
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
