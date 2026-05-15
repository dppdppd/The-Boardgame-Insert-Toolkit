// Test: A single no-margin compartment printed as its own PRINT_GROUP gets a
// printable rim/walls instead of only the base and chamfer helper geometry.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, false ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],

    [ OBJECT_BOX,
        [ NAME, "single compartment print group" ],
        [ PRINT_GROUP, "shell" ],
        [ BOX_NO_LID_B, true ],
        [ BOX_SIZE_XYZ, [72, 48, 18] ],
        [ BOX_FEATURE,
            [ PRINT_GROUP, "insert" ],
            [ CHAMFER_N, 1.5 ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [28, 20, 12] ],
            [ POSITION_XY, [12, 8] ],
        ],
    ],
];

module PrintGroup( group_name, rgb, offset = [0, 0, 0] )
{
    translate( offset )
        color( rgb )
            Make( data, print_group = group_name );
}

// Left: grouped box in final assembled position.
PrintGroup( "shell", [0.78, 0.78, 0.72] );
PrintGroup( "insert", [0.1, 0.42, 0.9] );

// Right: same groups exploded for geometry inspection.
PrintGroup( "shell", [0.78, 0.78, 0.72], [95, 0, 0] );
PrintGroup( "insert", [0.1, 0.42, 0.9], [180, 0, 0] );
