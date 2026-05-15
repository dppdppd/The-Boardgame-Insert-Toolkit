// Test: A single no-margin compartment printed as its own PRINT_GROUP gets a
// printable rim/walls instead of only the base and chamfer helper geometry.
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_TYPES, [ BOX, DIVIDERS ] ],

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

print_groups = [ "shell", "insert" ];

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

// Left: grouped box in final assembled position, using automatic colors.
PrintGroups();

// Right: same groups exploded for geometry inspection.
PrintGroup( "shell", [95, 0, 0] );
PrintGroup( "insert", [180, 0, 0] );
