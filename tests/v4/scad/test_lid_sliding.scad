// Test: Sliding lid - LID_TYPE = LID_SLIDING
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

inch = 25.4;
wall = 2;

// Standard poker cards are 2.5" x 3.5"; boxed decks are larger.
poker_pack_xyz = [ 2.625 * inch, 3.625 * inch, 0.75 * inch ];
pack_clearance_xyz = [ 0.125 * inch, 0.125 * inch, 0.15 * inch ];
interior_xyz = poker_pack_xyz + pack_clearance_xyz;
box_xyz = [
    interior_xyz[ k_x ] + 2 * wall,
    interior_xyz[ k_y ] + 2 * wall,
    interior_xyz[ k_z ] + 2 * wall
];

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ OBJECT_BOX,
        [ NAME, "sliding solid lid" ],
        [ BOX_SIZE_XYZ, box_xyz ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SOLID_B, t ],
            [ LABEL,
                [ LBL_TEXT, "SLIDE" ],
                [ LBL_SIZE, 8 ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, interior_xyz ],
        ],
    ],
    [ OBJECT_BOX,
        [ NAME, "left sliding pattern lid" ],
        [ BOX_SIZE_XYZ, box_xyz ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, LEFT ],
            [ LID_FRAME_WIDTH, 4 ],
            [ LID_PATTERN_RADIUS, 5 ],
            [ LID_PATTERN_THICKNESS, 0.8 ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, interior_xyz ],
        ],
    ],
];
Make(data);
