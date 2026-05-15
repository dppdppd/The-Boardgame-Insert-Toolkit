// Test: BOX_LID ENABLED_B can suppress lid output while keeping the box.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, LID ] ],
    [ OBJECT_BOX,
        [ NAME, "box with disabled lid" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_LID,
            [ ENABLED_B, false ],
            [ LID_PATTERN_RADIUS, 8 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
        ],
    ],
];
Make(data);
