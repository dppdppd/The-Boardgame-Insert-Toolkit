
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
g_wall_thickness = 1.5;

// this is the thickness of partitions between compartments
// Default = 1
g_partition_thickness = 0.5; // default = 1

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 6; 

data =
[
    [   "1",
        [
            [ "box_dimensions", [117, 27, 26.0] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       true ],
            [ "label",
                [
                    [ "text",   "BIOS: GENESIS"],
                    [ "size",   6 ]
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
                    [   "cubes",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 114, 24.0, 17.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, "max" ] ],                // [float, float, float]
                            ["rotation",            0 ],
                            ["label",               
                                [
                                    [ "text",   "CUBES"],
                                    [ "size",   4 ],
                                    [ "rotation", 0]
                                ]],
                        ]
                    ]
                ]
            ]     
        ]
    ],
    [   "2",
        [
            [ "box_dimensions", [57, 92, 26.0] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       true ],
            [ "visualization",
                [
                    [ "position",   [0,0,0] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "tokens",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack_compact"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_compact" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               "round"],
                            ["compartment_size",    [ 36.0, 17.0, 16.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 4] ],                   // [int, int]
                            ["position",            [-6, 0 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],
                    [   "dice",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 17.0, 71.0, 16.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            ["max", 0] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "DICE"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]],
                        ]
                    ],
                    [   "plugs",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 54.0, 17.5, 16.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, "max"] ],                // [float, float, float]
                            ["rotation",            -90 ],
                        ]
                    ],                    
                ]
            ]     
        ]
    ]
];


MakeAll();


