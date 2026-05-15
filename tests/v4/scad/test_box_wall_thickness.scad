// Test: Different wall thickness values
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, DIVIDERS ] ],
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
