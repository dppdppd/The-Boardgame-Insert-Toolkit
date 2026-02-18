// BITGUI
include <boardgame_insert_toolkit_lib.4.scad>;
// Toolkit that performs all the model generation operations
// Helper library to simplify creation of single components
// Also includes some basic lid helpers
// Determines whether lids are output.
g_b_print_lid = true;
// Determines whether boxes are output.
g_b_print_box = true;
// Only render specified box
g_isolated_print_box = "";
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
// Data structure processed by MakeAll();
data = [
    [ OBJECT_BOX, [
        // Box name, used for g_isolated_print_box
        [ NAME, "Box1" ],
        [ BOX_SIZE_XYZ, [box_urx, box_ury, box_urz] ],
        [ BOX_FEATURE, ftr_parms(dx =cmp_dx, dy =cmp_dy, dz =cmp_dz) ],
        // Another Key-Value pair to create the compartment
        [ BOX_LID, lid_parms(radius =8) ],
        // Another Key-Value pair to create the lid
    ]],
];
// Actually create the boxes based on the data structure above
MakeAll();