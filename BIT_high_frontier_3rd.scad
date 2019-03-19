
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

// this is the outer wall thickness. 
//Default = 2
g_wall_thickness = 2;

// this is the thickness of partitions between compartments
// Default = 1
g_partition_thickness = 1;

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 8; 


// 50 x 243 x 90
data =
[
    [   "1",
        [
            [ "box_dimensions", [243, 90, 48] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "label",
                [
                    [ "text",   "HIGH FRONTIER"],
                    [ "size",   12 ],
                    [ "rotation", 0],
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
                    [   "players",
                        [
                            ["enabled",             1],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               ""],
                            ["compartment_size",    [ 30.6, 50, 46] ],      // [float, float, float]
                            ["extra_spacing",       [0,0]],                     // [float,float]
                            ["num_compartments",    [5, 1] ],                   // [int, int]
                            ["position",            [0, 0 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],

                    [   "dots",
                        [
                            ["enabled",             1],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               ""],
                            ["compartment_size",    [ 40, 86, 46] ],      // [float, float, float]
                            ["extra_spacing",       [0,0]],                     // [float,float]
                            ["num_compartments",    [2, 1] ],                   // [int, int]
                            ["position",            ["max", 0 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],

                    [   "disks",
                        [
                            ["enabled",             1],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               ""],
                            ["compartment_size",    [ 32, 35, 46] ],      // [float, float, float]
                            ["extra_spacing",       [0,0]],                     // [float,float]
                            ["num_compartments",    [3, 1] ],                   // [int, int]
                            ["position",            [ 59, "max" ] ],                // [float, float, float]
                            ["rotation",            -90 ],
                        ]
                    ],

                    [   "dice",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 50.0, 13.0, 13] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [4, 55] ],                // [float, float, float]
                            ["rotation",            0 ],
                            ["label",               
                                [
                                    [ "text",   "DICE"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]],
                        ]
                    ],


                ]
            ]     
        ]
    ],

 
    
];


MakeAll();
