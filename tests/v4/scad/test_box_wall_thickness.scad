// Test: Different wall thickness values
include <boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ G_WALL_THICKNESS, 3.0 ],
    [ OBJECT_BOX,
        [ NAME, "thick walls" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [40, 40, 16] ],
        ],
    ],
];
Make(data);
