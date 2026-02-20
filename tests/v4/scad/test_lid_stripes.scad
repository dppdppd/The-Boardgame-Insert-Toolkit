// Test: Lid stripes — LID_STRIPE_WIDTH and LID_STRIPE_SPACE
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "striped lid" ],
        [ BOX_SIZE_XYZ, [60, 60, 15] ],
        [ BOX_LID,
            [ LID_STRIPE_WIDTH, 2 ],
            [ LID_STRIPE_SPACE, 3 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "wide stripes" ],
        [ BOX_SIZE_XYZ, [60, 60, 15] ],
        [ BOX_LID,
            [ LID_STRIPE_WIDTH, 5 ],
            [ LID_STRIPE_SPACE, 2 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 13] ],
        ],
    ],
];
Make(data);
