// Test: PRINT_GROUP can color-composite one intact box, then explode the
// same selected groups to verify each print pass has only its own geometry.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "print group box" ],
        [ PRINT_GROUP, "shell" ],
        [ BOX_NO_LID_B, true ],
        [ BOX_SIZE_XYZ, [68, 50, 18] ],
        [ LABEL,
            [ PRINT_GROUP, "ink" ],
            [ LBL_TEXT, "SIDE" ],
            [ LBL_SIZE, 5 ],
            [ LBL_PLACEMENT, FRONT ],
        ],
        [ BOX_FEATURE,
            [ PRINT_GROUP, "insert" ],
            [ CHAMFER_N, 0 ],
            [ FTR_NUM_COMPARTMENTS_XY, [2, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [24, 30, 12] ],
            [ FTR_PADDING_XY, [4, 1] ],
            [ FTR_MARGIN_FBLR, [2, 2, 2, 2] ],
            [ POSITION_XY, [5, 5] ],
            [ LABEL,
                [ PRINT_GROUP, "ink" ],
                [ LBL_TEXT, "A" ],
                [ LBL_SIZE, 6 ],
                [ LBL_PLACEMENT, BACK ],
            ],
            [ LABEL,
                [ PRINT_GROUP, "ink" ],
                [ LBL_TEXT, "B" ],
                [ LBL_SIZE, 6 ],
                [ LBL_PLACEMENT, BACK ],
                [ POSITION_XY, [4, 0] ],
            ],
        ],
    ],
];

module PrintGroup( group_name, rgb, offset = [0, 0, 0] )
{
    translate( offset )
        color( rgb )
            Make( data, print_group = group_name );
}

module PrintGroupBox()
{
    PrintGroup( "shell", [0.78, 0.78, 0.72] );
    PrintGroup( "insert", [0.1, 0.42, 0.9] );
    PrintGroup( "ink", [0.02, 0.02, 0.02] );
}

// Left: intact composite, with groups overlaid in their final positions.
PrintGroupBox();

// Right: the exact same print groups exploded so each pass can be inspected
// for unwanted shell/body geometry.
PrintGroup( "shell", [0.78, 0.78, 0.72], [95, 0, 0] );
PrintGroup( "insert", [0.1, 0.42, 0.9], [180, 0, 0] );
PrintGroup( "ink", [0.02, 0.02, 0.02], [245, 0, 0] );
