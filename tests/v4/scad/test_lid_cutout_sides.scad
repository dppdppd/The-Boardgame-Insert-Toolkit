// Test: Lid cutout sides — LID_CUTOUT_SIDES_4B
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "lid cutouts front-back" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID,
            [ LID_SOLID_B, t ],
            [ LID_CUTOUT_SIDES_4B, [t, t, f, f] ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ],
    ],
];
Make(data);
