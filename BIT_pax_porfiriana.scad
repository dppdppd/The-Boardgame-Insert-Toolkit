
include <boardgame_insert_toolkit_lib.scad>;



// determines whether lids are output.
g_b_print_lid = 0;

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
            [ "box_dimensions", [305, 145, 45] ],                       // float f -- default:[ 100, 100, 100]

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
                    [   "cards 1",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "cards"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 92, 62, 35 ] ],      // [float, float, float]
                            ["num_compartments",    [2,2] ],                   // [int, int]
                            ["position",            [0, "center" ] ],                // [float, float, float]
                            ["rotation",            0 ],
                            ["label",               
                                [
                                    [ "text",   "MEEPLE"],
                                    [ "size",   4 ]
                                ]],
                        ]
                    ],                
                ]
            ]     
        ]
    ],

    [   "2",
        [
            [ "box_dimensions", [57, 116, 26.5] ],                      // float f -- default:[ 100, 100, 100]

            [ "enabled",        0 ],
            [ "thin_lid",       true ],

            [ "visualization",
                [
                    [ "position",   [0,0,0] ],
                    [ "rotation",   0 ],
                ]
            ],                   

            [   "components",
                [
                    [   "tokens r",
                        [
                            ["enabled",             1],                        // true | false
                            ["type",                "chit_stack_vertical"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               "round"],
                            ["compartment_size",    [ 15.75, 15.75, 26.5] ],      // [float, float, float]
                            ["extra_spacing",       [0,.2]],                     // [float,float]
                            ["num_compartments",    [1, 5] ],                   // [int, int]
                            ["position",            [-9, 1 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],
                    [   "tokens l",
                        [
                            ["enabled",             1],                        // true | false
                            ["type",                "chit_stack_vertical"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               "round"],
                            ["compartment_size",    [ 15.75, 15.75, 26.5] ],      // [float, float, float]
                            ["extra_spacing",       [0,.2]],                     // [float,float]
                            ["num_compartments",    [1, 5] ],                   // [int, int]
                            ["position",            [40, 1 ] ],                // [float, float, float]
                            ["rotation",            -90 ],
                        ]
                    ],
                    [   "chits",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 54, 17, 26] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, "max"] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "CHITS"],
                                    [ "size",   4 ],
                                    [ "rotation", 0]
                                ]
                            ],
                        ]
                    ],

                    [   "dice",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_compact" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 16, 70, 26] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [ 23, 0 ] ],                // [float, float, float]
                            ["rotation",            0 ],
                            ["label",               
                                [
                                    [ "text",   "DICE"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]
                            ],
                        ]
                    ],

                    [   "big meeple",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 54, 11, 22.5] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [ "center", 84 ] ],                // [float, float, float]
                            ["rotation",            90 ],

                            ["label",               
                                [
                                    [ "text",   "HUNTERS"],
                                    [ "size",   4 ],
                                    [ "rotation", 0]
                                ]
                            ],
                        ]
                    ],

                    [   "arrow",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack_compact"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 5, 32, 11] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [ 16, -8 ] ],                // [float, float, float]
                            ["rotation",            0 ],
                        ]
                    ],
                ]
            ]     
        ]
    ],
];


MakeAll();
