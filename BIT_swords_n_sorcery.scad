
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
g_wall_thickness = 1;

// this is the thickness of partitions between compartments
// Default = 1
g_partition_thickness = 1;

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 9; 


// 265 x 395 x 85
data =
[
    [   "cards",
        [
            [ "box_dimensions", [170, 250, 24] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "label",
                [
                    [ "text",   ""],
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
                    [   "cards",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 72, 49, 22] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,-0.5]],                     // [float,float]
                            ["num_compartments",                [2, 5] ],                   // [int, int]
                            ["position",                        ["center", "center" ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "chits",
        [
            [ "box_dimensions", [170, 250, 27] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "label",
                [
                    [ "text",   ""],
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
                    [   "chits",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 32.8, 36, 26] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,0]],                     // [float,float]
                            ["num_compartments",                [5, 3] ],                   // [int, int]
                            ["position",                        ["center", 0 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],
                    [   "chits",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 32.8, 36, 26] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,0]],                     // [float,float]
                            ["num_compartments",                [3, 1] ],                   // [int, int]
                            ["position",                        ["max", 111 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],                    
                    [   "chits",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 32.8, 52, 26] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,0]],                     // [float,float]
                            ["num_compartments",                [3, 1] ],                   // [int, int]
                            ["position",                        ["max", 148 ] ],                // [float, float, float]
                            ["rotation",                        -90 ],
                        ]
                    ],
                    [   "gold",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "chit_stack_compact"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "round"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 25.5, 12, 26] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,0]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        [0, 111 ] ],                // [float, float, float]
                            ["rotation",                        180 ],
                        ]
                    ],
                    [   "silver",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "chit_stack_compact"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "round"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 20.5, 35, 21] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,0]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        [46, 158 ] ],                // [float, float, float]
                            ["partition_rotation",              180 ],
                        ]
                    ],   
                    [   "copper",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "chit_stack_compact"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "round"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 18, 35, 19] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,0]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        [48, 113 ] ],                // [float, float, float]
                            ["rotation",                        0 ],
                        ]
                    ],                  
                    [   "chits",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 83.5, 45, 26] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,0]],                     // [float,float]
                            ["num_compartments",                [2, 1] ],                   // [int, int]
                            ["position",                        ["center", "max" ] ],                // [float, float, float]
                            ["rotation",                        0 ],
                        ]
                    ],      

                    [   "dice",
                        [
                            ["type",                        "decahedron"],
                            ["compartment_size",            [ 20, 20.0, 22.0] ], 
                            ["num_compartments",            [2, 4] ], 
                            ["rotation",                    0],
                            ["position",                    [0,119]]
                        ]
                    ],                                                  
                ]
            ]
        ]
    ],

 
    
];


MakeAll();
