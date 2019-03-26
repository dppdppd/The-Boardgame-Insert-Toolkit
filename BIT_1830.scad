
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
g_partition_thickness = 1;

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 9; 


// 285 X 220 X 60 
data =
[
    [   "spacer",
        [
            [ "box_dimensions", [40, 220, 30] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "type",           "spacer"],
            [ "label",
                [
                    [ "text",   ""],
                    [ "size",   12 ],
                    [ "rotation", 0],
                ]
            ],
        ]
    ],
    [   "tiles",
        [
            [ "box_dimensions", [70, 220, 46] ],                       // float f -- default:[ 100, 100, 100]

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
                    [   "tiles",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "hex_rotated"],                 // "round" | "hex" | "hex_rotated" | "square" -- default: "square"
                            ["compartment_size",                [ 64, 39, 45] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0,4]],                     // [float,float]
                            ["num_compartments",                [1, 5] ],                   // [int, int]
                            ["position",                        ["center", "center" ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "1",
        [
            [ "box_dimensions", [110, 220, 57] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "label",
                [
                    [ "text",   "1830"],
                    [ "size",   20 ],
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
                    [   "shares",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],
                            ["compartment_size",                [ 7, 71, 44] ],      // [float, float, float]
                            ["partition_size_adjustment",       [-0.8,0]],                     // [float,float]
                            ["partition_height_adjustment",     [0, -22]],                     // [float,float]                            
                            ["num_compartments",                [4, 3] ],                   // [int, int]
                            ["position",                        [0, "center" ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],

                    [   "cards",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],
                            ["compartment_size",                [ 20, 71, 44] ],      // [float, float, float]
                            ["partition_size_adjustment",       [1, 0]],                     // [float,float]
                            ["num_compartments",                [1, 1] ],                   // [int, int]
                            ["position",                        ["max", 3 ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],

                    [   "chits",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           ""],
                            ["compartment_size",                [ 36.5, 70, 30] ],      // [float, float, float]
                            ["partition_size_adjustment",       [0, 0]],                     // [float,float]
                            ["num_compartments",                [1, 2] ],                   // [int, int]
                            ["position",                        ["max", 75 ] ],                // [float, float, float]
                            ["rotation",                        -90 ],
                        ]
                    ],

                ]
            ]     
        ]
    ],

    [   "money",
        [
            [ "box_dimensions", [63, 220, 57] ],                       // float f -- default:[ 100, 100, 100]

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
                    [   "money",
                        [
                            ["enabled",                         1],                        // true | false
                            ["type",                            "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",                           "square"],
                            ["compartment_size",                [ 7, 107, 56] ],      // [float, float, float]
                            ["partition_size_adjustment",       [-3,0]],                     // [float,float]
                            ["partition_height_adjustment",     [6, -12]],                     // [float,float]
                            ["num_compartments",                [4, 2] ],                   // [int, int]
                            ["position",                        [0, "center" ] ],                // [float, float, float]
                            ["rotation",                        90 ],
                        ]
                    ],
                ]
            ]     
        ]
    ],
    

 
    
];


MakeAll();
