// Test: Compartment margins — FTR_MARGIN_FBLR [front, back, left, right]
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "uniform margin" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [30, 30, 18] ],
            [ FTR_MARGIN_FBLR, [10, 10, 10, 10] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "front-heavy margin" ],
        [ BOX_SIZE_XYZ, [60, 80, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [50, 30, 18] ],
            [ FTR_MARGIN_FBLR, [30, 0, 0, 0] ],
        ],
    ],
];
Make(data);
