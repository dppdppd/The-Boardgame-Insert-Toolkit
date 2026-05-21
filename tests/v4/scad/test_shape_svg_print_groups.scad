// Test: SVG feature shapes participate in split print-group output.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, BOX ],
    [ G_PRINT_GROUPS, [ "shell", "insert" ] ],

    [ OBJECT_BOX,
        [ NAME, "svg print groups" ],
        [ PRINT_GROUP, "shell" ],
        [ BOX_NO_LID_B, true ],
        [ BOX_SIZE_XYZ, [70, 50, 18] ],
        [ BOX_FEATURE,
            [ PRINT_GROUP, "insert" ],
            [ CHAMFER_N, 0 ],
            [ FTR_SHAPE,
              [ SVG,
                [ SVG_FILE, "../assets/meeple.svg" ],
                [ SVG_WIDTH_MM, 11 ],
                [ SVG_CLEARANCE_MM, 0.5 ],
              ],
            ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 28, 14] ],
            [ POSITION_XY, [CENTER, CENTER] ],
        ],
    ],
];

Make(data);
