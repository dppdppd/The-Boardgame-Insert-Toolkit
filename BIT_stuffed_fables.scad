
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
//Default = 1.5
g_wall_thickness = 1.5;

// this is the thickness of partitions between compartments
// Default = 1
g_partition_thickness = 1.0;

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 8; 


// 285 x 285 x 50
data =
[
    [   "cards",
        [
            [ "box_dimensions", [203, 94, 30] ],                       // float f -- default:[ 100, 100, 100 ]

            [ "enabled",        1],
            [ "thin_lid",       false ],
            [ "visualization",
                [
                    [ "position",   [0, 0, 0 ] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "cards",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 66, 91, 28] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [3, 1] ],                   // [int, int]
                            ["position",                        ["center", "center" ] ],                // [float, float, float]
                            ["rotation",                        0 ],
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "cards",
        [
            [ "box_dimensions", [203, 94, 16] ],                       // float f -- default:[ 100, 100, 100 ]

            [ "enabled",        1],
            [ "thin_lid",       false ],
            [ "visualization",
                [
                    [ "position",   [0, 0, 26 ] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "cards",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 66, 91, 14] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [3, 1] ],                   // [int, int]
                            ["position",                        ["center", "center" ] ],                // [float, float, float]
                            ["rotation",                        0 ],
                        ]
                    ],
                ]
            ]
        ]
    ],    
    [   "minis",
        [
            [ "box_dimensions", [194, 182, 45] ],                       // float f -- default:[ 100, 100, 100 ]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "label",
                [
                    [ "text",   "STUFFED FABLES"],
                    [ "size",   10 ],
                    [ "rotation", 0 ],
                ]
            ],
            [ "visualization",
                [
                    [ "position",   [0, 95, 0 ] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "mongrel",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 46, 38, 40] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [2, 2] ],                   // [int, int]
                            ["position",                        [34, "max" ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "MONGREL"],
                                    [ "size",   4 ]
                                ]
                            ],
                        ]
                    ], 
                    [   "dark heart",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 31, 38, 36] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [2, 2] ],                   // [int, int]
                            ["position",                        ["max", "max" ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "DARK HEART"],
                                    [ "size",   3 ],
                                    ["rotation",    0],
                                ]
                            ],
                        ]
                    ],
                    [   "crepitus",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 28, 67, 43] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1,1] ],                   // [int, int]
                            ["position",                        [34, 34 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "CREPITUS"],
                                    [ "size",   4 ]
                                ]
                            ],
                        ]
                    ],                                                              
                    [   "snatcher",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 80, 67, 43] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        [63, 34 ] ],                // [float, float, float]
                            ["rotation",                        0 ],
                            ["label",               
                                [
                                    [ "text",   "SNATCHER"],
                                    [ "size",   4 ]
                                ]
                            ],
                        ]
                    ],
                    [   "skreela",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [52, 33, 30] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        ["max", 0 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "SKREELA"],
                                    [ "size",   4 ],
                                    [ "rotation",   0]
                                ]
                            ],
                        ]
                    ],         
                    [   "knuckle",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 57, 33, 38] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        [81, 0 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "KNUCKLE"],
                                    [ "size",   4 ],
                                    [ "rotation",   0]
                                ]
                            ],
                        ]
                    ],      
                    [   "dollmaker",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 46, 33, 30] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        [34, 0 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "DOLLMAKER"],
                                    [ "size",   4 ],
                                    [ "rotation",   0]
                                ]
                            ],
                        ]
                    ],   
                    [   "crawly",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 22, 33, 38] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [2, 2] ],                   // [int, int]
                            ["position",                        ["max", 34 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "CRAWLY"],
                                    [ "size",   4 ],
                                    [ "rotation",  90]
                                ]
                            ],
                        ],
                    ],
                    [   "heroes",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 33, 29, 35] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1, 6] ],                   // [int, int]
                            ["position",                        [0,0  ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                            ["label",               
                                [
                                    [ "text",   "HERO"],
                                    [ "size",   4 ],
                                    [ "rotation",  0]
                                ]
                            ],
                        ]
                    ],   

                ]
            ]
        ]
    ],
    [   "chits",
        [
            [ "box_dimensions", [85, 185, 40] ],                       // float f -- default:[ 100, 100, 100 ]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "visualization",
                [
                    [ "position",   [205, 0, 0 ] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "cards",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 70, 46, 20] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        [-2, "max" ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],
                    [   "dice",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 82, 26, 38] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        ["center", 0 ] ],                // [float, float, float]
                            ["rotation",                        0 ],
                        ]
                    ],
                    [   "tokens",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 26, 37, 15] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [3, 1] ],                   // [int, int]
                            ["position",                        ["center", 27 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],
                    [   "tokens",
                        [
                            ["enabled",                         1 ],                        // true | false
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 26, 70, 35] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0 ]],                     // [float,float]
                            ["num_compartments",                [3, 1] ],                   // [int, int]
                            ["position",                        ["center", 65 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],                    
                      
                ]
            ]
        ]
    ],

 
    
];


MakeAll();
