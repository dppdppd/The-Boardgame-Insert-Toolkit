// Toolkit that performs all the model generation operations
include <boardgame_insert_toolkit_lib.2.scad>;

// Helper library to simplify creation of single components
// Also includes some basic lid helpers
include <bit_functions_lib.scad>;

// Determines whether lids are output.
g_b_print_lid = true;

// Determines whether boxes are output.
g_b_print_box = true; 

// Only render specified box
g_isolated_print_box = "hexbox example 1"; 

// Used to visualize how all of the boxes fit together. 
g_b_visualization = false;          
        
// Outer wall thickness
// Default = 1.5mm
g_wall_thickness = 1.5;

// Provided to make variable math easier
// i.e., it's a lot easier to just type "wall" than "g_wall_thickness"
wall = g_wall_thickness;

// The tolerance value is extra space put between planes of the lid and box that fit together.
// Increase the tolerance to loosen the fit and decrease it to tighten it.
//
// Note that the tolerance is applied exclusively to the lid.
// So if the lid is too tight or too loose, change this value ( up for looser fit, down for tighter fit ) and 
// you only need to reprint the lid.
// 
// The exception is the stackable box, where the bottom of the box is the lid of the box below,
// in which case the tolerance also affects that box bottom.
//
g_tolerance = 0.15;

// This adjusts the position of the lid detents downward. 
// The larger the value, the bigger the gap between the lid and the box.
g_tolerance_detents_pos = 0.1;

// This sets the default font for any labels. 
// See https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text#Using_Fonts_&_Styles
// for details on picking a new font.
g_default_font = "Liberation Sans:style=Regular";

// This determines whether the default single material version is output, or, if printing in multiple materials, 
// which layer to output.
g_print_mmu_layer = "default"; // [ "default" | "mmu_box_layer" | "mmu_label_layer" ]

////////////////////////////////////////////////////////////////////////////////
// User data for box creation
////////////////////////////////////////////////////////////////////////////////

// Variables for Box1
// The lower left corner of the box sits at (0, 0, 0)
// This defines the upper right corner of the box, i.e., the size
// Note that box_urz subtracts out 2*wall to have a final height of 20mm with an inset lid
box_urx = 100;
box_ury = 120;
box_urz = 20 - 2*wall;

// This math defines the size of a single square component that fills the box
cmp_dx = box_urx - 2*wall;
cmp_dy = box_ury - 2*wall;
cmp_dz = box_urz - 1*wall;

// Variables for Box1
// Note that box_urz subtracts out 2*wall to have a final height of 20mm with an inset lid
// Hexbox sizing is determined by the inner diameter (i.e., measure across a Tile you want to fit inside)
hexbox_d = 100;
hexbox_urz = 20 - 2*wall;

// This math defines the size of a single square component that fills the box
hexcmp_d = hexbox_d;
hexcmp_dz = hexbox_urz - 1*wall;

// These variables help with the actual dimensions of the box itself
hexbox_inner_diameter = hexbox_d;                                 // Measured long way across inside of the box
hexbox_inner_inradius = (hexbox_inner_diameter / 2.0) * sin(60);  // Measured from center point perpendicularly to inside of wall
hexbox_outer_inradius = hexbox_inner_inradius + g_wall_thickness; // Measured from center point perpendicularly to outside of wall
hexbox_outer_diameter = (2 * hexbox_outer_inradius) / sin(60);    // Measured long way across outside of box

// Data structure processed by MakeAll();
data =
[
    [   "Box1",                                                              // Box name, used for g_isolated_print_box
        [
            [ BOX_SIZE_XYZ, [box_urx, box_ury, box_urz] ],                   // One Key-Value pair specifying the upper right x, y, and z of our box exterior.
            [ BOX_COMPONENT, cmp_parms( dx=cmp_dx, dy=cmp_dy, dz=cmp_dz ) ], // Another Key-Value pair to create the compartment
            [ BOX_LID, lid_parms( radius = 8 ) ],                            // Another Key-Value pair to create the lid
        ]
    ],


    [   "HexBox1",                                                             // Box name, used for g_isolated_print_box
        [
            [ TYPE, HEXBOX ],                                                  // Tell the toolkit this is a hexbox
            [ HEXBOX_SIZE_DZ, [hexbox_d, hexbox_urz] ],                        // One Key-Value pair specifying the size of the hexbox
            [ BOX_COMPONENT, cmp_parms_hex_tile( d=hexcmp_d, dz=hexcmp_dz ) ], // Another Key-Value pair to create the compartment
            [ BOX_LID, lid_parms( radius = 8 ) ],                              // Another Key-Value pair to create the lid
        ]
    ],

];

// Actually create the boxes based on the data structure above
MakeAll();
