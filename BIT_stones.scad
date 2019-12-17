
include <boardgame_insert_toolkit_lib.scad>;

// determines whether lids are output.
g_b_print_lid = 1;

// determines whether boxes are output.
g_b_print_box = 1; 

// Focus on one box
g_isolated_print_box = ""; 

// Used to visualize how all of the boxes fit together. 
// Turn off for printing.
g_b_visualization = 0;          

// Makes solid simple lids instead of the honeycomb ones.
// Might be faster to print. Definitely faster to render.
g_b_simple_lids = 0;            


// creates the indentation on the bottom of the box 
//that allows the lid to be put under when in play.
g_b_fit_lid_underneath = 1; 
g_wall_underside_lid_storage_depth = 2;

g_wall_lip_height = 5;

// makes the box exterior simple
g_b_simple_exterior = 1;

g_b_lid_notches = true;

// this is the outer wall thickness. 
//Default = 2
g_wall_thickness = 2;


// this is the thickness of partitions between compartments
// Default = 1
g_partition_thickness = 1; // default = 1

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 13; 

g_tolerance = 0.1; 

data =
[
    [   "1",
        [
            [ "box_dimensions",                             [69, 69, 22] ],      // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    1 ],
 
            [   "components",
                [
                    [   "",
                        [
                            ["compartment_size",            [ 65, 65, 20.0] ],        // float f -- default:[ 10, 10, 10]
                  //           ["type",                        "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["position",                    ["center", "center" ] ],                // [float, float, float]
                       //     ["num_compartments",            [5, 1] ],                   // [int, int]
                            ["rotation",                        90 ],
                        ]
                    ]
                ]
            ]
        ]
    ]
];


MakeAll();
