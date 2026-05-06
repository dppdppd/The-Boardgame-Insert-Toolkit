// Test: Sliding lid with lid label for print-side orientation
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

wall = 2;
box_xyz = [70, 52, 24];
interior_xyz = [box_xyz[k_x] - 2*wall, box_xyz[k_y] - 2*wall, box_xyz[k_z] - 2*wall];

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    [ G_LID_THICKNESS, 3 ],
    [ OBJECT_BOX,
        [ NAME, "sliding labeled lid" ],
        [ BOX_SIZE_XYZ, box_xyz ],
        [ BOX_WALL_THICKNESS, wall ],
        [ BOX_LID,
            [ LID_TYPE, LID_SLIDING ],
            [ LID_SLIDE_SIDE, FRONT ],
            [ LID_SOLID_B, true ],
            [ LABEL,
                [ LBL_TEXT, "TOP LID" ],
                [ LBL_SIZE, 9 ],
                [ POSITION_XY, [0, 4] ],
            ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, interior_xyz ],
            [ FTR_CUTOUT_TYPE, EXTERIOR ],
            [ FTR_CUTOUT_SIDES_4B, [false, false, true, true] ],
            [ FTR_CUTOUT_DEPTH_PCT, 5 ],
            [ FTR_CUTOUT_HEIGHT_PCT, 100 ],
  
  ],
    ],
];
Make(data);
