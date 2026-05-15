// Test: PRINT_GROUP can color-composite one intact box, then explode the
// same selected groups to verify each print pass has only its own geometry.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, DIVIDERS ] ],

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

print_groups = [ "shell", "insert", "ink" ];

module PrintGroups( offset = [0, 0, 0] )
{
    translate( offset )
        Make( data, print_groups = print_groups );
}

module PrintGroup( group_name, offset = [0, 0, 0] )
{
    translate( offset )
        Make( data, print_groups = group_name );
}

// Left: intact composite, with automatic print-group preview colors.
PrintGroups();

// Right: the exact same print groups exploded so each pass can be inspected
// for unwanted shell/body geometry.
PrintGroup( "shell", [95, 0, 0] );
PrintGroup( "insert", [180, 0, 0] );
PrintGroup( "ink", [245, 0, 0] );
