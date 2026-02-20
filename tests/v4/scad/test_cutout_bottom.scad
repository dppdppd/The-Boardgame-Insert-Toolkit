// Test: Bottom cutouts — FTR_CUTOUT_BOTTOM_B and FTR_CUTOUT_BOTTOM_PCT
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "bottom cutout" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
            [ FTR_CUTOUT_BOTTOM_B, t ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "bottom cutout 50pct" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
            [ FTR_CUTOUT_BOTTOM_B, t ],
            [ FTR_CUTOUT_BOTTOM_PCT, 50 ],
        ],
    ],
];
Make(data);
