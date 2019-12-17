
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
g_b_simple_lids = 1;            


// creates the indentation on the bottom of the box 
//that allows the lid to be put under when in play.
g_b_fit_lid_underneath = 1; 
g_wall_underside_lid_storage_depth = 1;

g_wall_lip_height = 7;

// makes the box exterior simple
g_b_simple_exterior = 0;

g_b_lid_notches = false;

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

g_tolerance = 0.05; 

data =
[
    [   "1",
        [
            [ "box_dimensions",                             [224.0, 89.0, 17.0] ],      // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    1 ],
            [ "label",
                [
                    [ "text",   "WET PALETTE"],
                    [ "size",   10 ],
                    [ "rotation", 0 ],
                ]
            ],
            [   "components",
                [
                    [   "",
                        [
                            ["compartment_size",            [ 220, 85.0, 15.0] ],        // float f -- default:[ 10, 10, 10]
                        ]
                    ]
                ]
            ]
        ]
    ],

    [   "1",
        [
            [ "box_dimensions",                             [50.0, 50.0, 10.0] ],      // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    0 ],
            [   "components",
                [
                    [   "",
                        [
                            ["compartment_size",            [ 46, 46.0, 8.0] ],        // float f -- default:[ 10, 10, 10]
                        ]
                    ]
                ]
            ]
        ]
    ],
];


MakeAll();
