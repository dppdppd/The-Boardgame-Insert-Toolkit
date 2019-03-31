
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
g_finger_partition_thickness = 10; 

// 152 x 305 x 48

// 100 x 76 x 48

data =
[
    [   "spacer",
        [
            [ "box_dimensions", [46, 80, 19] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "type",           "spacer"],
            [ "thin_lid",       false ],
            [ "visualization",
                [
                    [ "position",   [0,0,0] ],
                    [ "rotation",   0 ],
                ]
            ],   
        ]
    ],
    [   "spacer",
        [
            [ "box_dimensions", [27, 152, 46] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "type",           "spacer"],
            [ "thin_lid",       false ],
            [ "visualization",
                [
                    [ "position",   [0,0,0] ],
                    [ "rotation",   0 ],
                ]
            ],   
        ]
    ],
    [   "4 of these",
        [
            [ "box_dimensions", [80, 46, 32] ],                       // float f -- default:[ 100, 100, 100]

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
                    [   "creeples",
                        [
                            ["enabled",                     1 ],                        // true | false
                            ["type",                        "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",            [ 12, 44.0, 26.0] ],      // [float, float, float]
                            ["num_compartments",            [4, 1] ],                   // [int, int]
                            ["partition_height_adjustment", [-9,0]],                   // adjust x and y partition height
                            ["position",                    [0, "center" ] ],                // [float, float, float]
                            ["rotation",                    0 ],
                            ["label",               
                                [
                                    [ "text",   "CREEPLES"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]],
                        ]
                    ],
                    [   "dice",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 13, 43.0, 30.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            ["max", "center" ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "DICE"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]],
                        ]
                    ],
                    [   "domes",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 12.5, 43.0, 20.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [50.5, "center" ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "DOMES"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]],
                        ]
                    ]
                ]
            ]     
        ]
    ],

    [   "2",
        [
            [ "box_dimensions", [152, 200, 46] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       false ],
            [ "label",
                [
                    [ "text",   "BIOS: MEGAFAUNA"],
                    [ "size",   10 ],
                    ["rotation", 90]
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
                            ["enabled",             1 ],                        // true | false
                            ["type",                "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 63, 93.0, 40.0] ],      // [float, float, float]
                            ["num_compartments",    [2, 1] ],                   // [int, int]
                            ["position",            ["center", 0 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],

                    [   "cubes",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 29.3, 37.0, 25.0] ],      // [float, float, float]
                            ["num_compartments",    [5, 1] ],                   // [int, int]
                            ["position",            ["center", 94 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "CUBES"],
                                    [ "size",   4 ],
                                    [ "rotation", 0]
                                ]],
                        ]
                    ],

                    [   "disks",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 49, 30.0, 20.0] ],      // [float, float, float]
                            ["num_compartments",    [3, 1] ],                   // [int, int]
                            ["position",            ["center", 132 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "DISKS"],
                                    [ "size",   4 ],
                                    [ "rotation", 0]
                                ]],
                        ]
                    ],  
                    [   "dice",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 50, 13.0, 13.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            ["center", "max" ] ],                // [float, float, float]
                            ["rotation",            0 ],
                        ]
                    ],                  
                    [   "fossils",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               "round"],
                            ["compartment_size",    [ 28, 26.0, 40.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, "max" ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],   
                    [   "chits",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               "hex"],
                            ["compartment_size",    [ 28, 31.0, 40.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            ["max", "max" ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],                

                ]
            ]     
        ]
    ],    
];


MakeAll();


