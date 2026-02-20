// Test: Corner cutouts — FTR_CUTOUT_CORNERS_4B
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "all corner cutouts" ],
        [ BOX_SIZE_XYZ, [55, 55, 10] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
            [ FTR_SHAPE, HEX2 ],
            [ FTR_SHAPE_VERTICAL_B, t ],
            [ FTR_CUTOUT_CORNERS_4B, [t, t, t, t] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "diagonal corner cutouts" ],
        [ BOX_SIZE_XYZ, [55, 55, 10] ],
        [ BOX_FEATURE,
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
            [ FTR_SHAPE, HEX2 ],
            [ FTR_SHAPE_VERTICAL_B, t ],
            [ FTR_CUTOUT_CORNERS_4B, [t, f, t, f] ],
        ],
    ],
];
Make(data);
