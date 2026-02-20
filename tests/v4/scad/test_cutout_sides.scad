// Test: Side cutouts — FTR_CUTOUT_SIDES_4B with various combinations
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "front-back cutouts" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
            [ FTR_CUTOUT_SIDES_4B, [t, t, f, f] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "all sides cutout" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
            [ FTR_CUTOUT_SIDES_4B, [t, t, t, t] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "left only cutout" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
            [ FTR_CUTOUT_SIDES_4B, [f, f, f, t] ],
        ],
    ],
];
Make(data);
