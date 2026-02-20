// Test: Lid tabs — LID_TABS_4B
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "all tabs" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID,
            [ LID_SOLID_B, t ],
            [ LID_TABS_4B, [t, t, t, t] ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "front-back tabs only" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID,
            [ LID_SOLID_B, t ],
            [ LID_TABS_4B, [t, t, f, f] ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ],
    ],
];
Make(data);
