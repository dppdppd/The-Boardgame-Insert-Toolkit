// BGSD
include <boardgame_insert_toolkit_lib.4.scad>;
// Toolkit that performs all the model generation operations
// Helper library to simplify creation of single components
// Also includes some basic lid helpers
// Variables for Box1
// The lower left corner of the box sits at (0, 0, 0)
// This defines the upper right corner of the box, i.e., the size
// Note that box_urz subtracts out 2*wall to have a final height of 20mm with an inset lid
wall = $g_wall_thickness;
box_urx = 100;
box_ury = 120;
box_urz = 20 - 2*wall;
// This math defines the size of a single square component that fills the box
cmp_dx = box_urx - 2*wall;
cmp_dy = box_ury - 2*wall;
cmp_dz = box_urz - 1*wall;
// Data structure processed by Make()
data = [
    // Globals
    [ G_TOLERANCE, 0.15 ],
    [ OBJECT_BOX,
        [ NAME, "Box1" ],
        [ BOX_SIZE_XYZ, [box_urx, box_ury, box_urz] ],
        ftr_parms(dx =cmp_dx, dy =cmp_dy, dz =cmp_dz),
        lid_parms(radius =8),
    ],
];
// Actually create the boxes based on the data structure above
Make(data);