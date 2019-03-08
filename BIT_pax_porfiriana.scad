
include <boardgame_insert_toolkit_lib.scad>;



// determines whether lids are output.
g_b_print_lid = true;

// determines whether boxes are output.
g_b_print_box = true; 

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

// this is the outer wall thickness. 
//Default = 2
g_wall_thickness = 2.0;

// this is the thickness of partitions between compartments
// Default = 1
g_partition_thickness = 1.0; // default = 1

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 13; 

// depth: 46mm

data =
[
    [   "1",
        [
            [ "box_dimensions", [191, 141, 40] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],

            [ "visualization",
                [
                    [ "position",   [0,0,0] ],
                    [ "rotation",   0 ],
                ]
            ],     
            [ "label",
                [
                    [ "text",   "PAX PORFIRIANA"],
                    [ "size",   12 ]
                ]
            ],              

            [   "components",
                [
                    [   "cards 1",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "cards"],                   // "cards" | "cards_compact" | "tokens" | "chit_stack" | "chit_stack_compact" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 93, 62, 38 ] ],      // [float, float, float]
                            ["num_compartments",    [2,2] ],                   // [int, int]
                            ["position",            [0, "center" ] ],                // [float, float, float]
                            ["rotation",            0 ],
                        ]
                    ],  
                ]
            ]     
        ]
    ],

    [   "2",
        [
            [ "box_dimensions", [112, 141, 40] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],

            [ "visualization",
                [
                    [ "position",   [0,0,0] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "cubes",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 35, 45, 30] ],      // [float, float, float]
                            ["num_compartments",    [3, 3] ],                   // [int, int]
                            ["position",            ["center", "center"] ],                // [float, float, float]
                        //    ["extra_spacing",       [5,5]],
                            ["rotation",            -90 ],
                        ]
                    ],                    

                ]
            ]     
        ]
    ],


];


MakeAll();
