
include <boardgame_insert_toolkit_lib.scad>;



// determines whether lids are output.
g_b_print_lid = 1;

// determines whether boxes are output.
g_b_print_box = 1; 

// Focus on one box
g_isolated_print_box = "1"; 

// Used to visualize how all of the boxes fit together. 
// Turn off for printing.
g_b_visualization = 0;          

// Makes solid simple lids instead of the honeycomb ones.
// Might be faster to print. Definitely faster to render.
g_b_simple_lids = 0;            


// creates the indentation on the bottom of the box 
//that allows the lid to be put under when in play.
g_b_fit_lid_underneath = 1; 

// total indonesia box interior dimensions: 115 x 115 x 50
// 

data =
[
    [   "1",
        [
            [ "box_dimensions", [115, 115, 48.0] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "label",
                [
                    [ "text",   "Cards"],
                    [ "size",   12 ]
                ]
            ],
            [ "visualization",
                [
                    [ "position",   [0,0,0] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "cards 1",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 59.0, 90.0, 46.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, -13 ] ],                // [float, float, float]
                            ["rotation",            0 ],
                        ]
                    ],

                ]
            ],
        ]
    ],  
    
];


MakeAll();
