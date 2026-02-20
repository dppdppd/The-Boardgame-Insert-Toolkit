// Test: Positioning — CENTER and explicit XY positions
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "centered component" ],
        [ BOX_SIZE_XYZ, [80, 80, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [30, 30, 18] ],
            [ POSITION_XY, [CENTER, CENTER] ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "explicit positioned" ],
        [ BOX_SIZE_XYZ, [80, 80, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ POSITION_XY, [5, 5] ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ POSITION_XY, [50, 50] ],
        ],
    ],
];
Make(data);
