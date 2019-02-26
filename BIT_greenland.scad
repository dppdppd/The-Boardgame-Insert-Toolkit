
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
g_finger_partition_thickness = 8; 

// depth: 46mm

data =
[
    [   "1",
        [
            [ "box_dimensions", [57, 116, 22] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       true ],
            [ "label",
                [
                    [ "text",   "GREENLAND"],
                    [ "size",   5 ]
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
                    [   "agents",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 54, 27.8, 21.5] ],      // [float, float, float]
                            ["num_compartments",    [1, 4] ],                   // [int, int]
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
            [ "box_dimensions", [57, 116, 25.5] ],                      // float f -- default:[ 100, 100, 100]

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
                    [   "tokens r",
                        [
                            ["enabled",             1],                        // true | false
                            ["type",                "chit_stack_vertical"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               "round"],
                            ["compartment_size",    [ 15.75, 15.75, 25.5] ],      // [float, float, float]
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
                            ["compartment_size",    [ 15.75, 15.75, 25.5] ],      // [float, float, float]
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
                            ["compartment_size",    [ 54, 18, 25] ],      // [float, float, float]
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
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 23, 79.5, 25] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            ["center", 0 ] ],                // [float, float, float]
                            ["rotation",            90 ],
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
                            ["position",            [ "center", 83 ] ],                // [float, float, float]
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
                ]
            ]     
        ]
    ],
];


MakeAll();
