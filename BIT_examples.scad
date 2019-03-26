
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
g_partition_thickness = 1; // default = 1

// this is the width of partitions that are for 
// inserting fingers to grab the bits.
// default = 13
g_finger_partition_thickness = 13; 

data =
[
    [   "1",
        [
            [ "box_dimensions",                             [150.0, 100.0, 30.0] ],      // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],
            [   "components",
                [
                    [   "cards comaact",
                        [
                            ["type",                        "cards_compact"],                   // "cards" | "tokens" | "chit_stack" | "" -- default: ""
                            ["compartment_size",            [ 40, 40.0, 20.0] ],        // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [1,2] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    90 ],                       
                            ["position",                    [-10,"center"]]        // float f | "center" | "max" -- default: "center"
                        ]
                    ],

                   [   "cards",
                        [
                            ["type",                        "cards"],                   // "cards" | "tokens" | "chit_stack" | "" -- default: ""
                            ["compartment_size",            [ 40, 40.0, 20.0] ],        // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [1,2] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    0 ],                       
                            ["position",                    ["center","center"]]        // float f | "center" | "max" -- default: "center"
                        ]
                    ],

                   [   "cards",
                        [
                            ["type",                        "cards_compact"],                   // "cards" | "tokens" | "chit_stack" | "" -- default: ""
                            ["compartment_size",            [ 40, 40.0, 20.0] ],        // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [1,2] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    0 ],                       
                            ["position",                    ["max","center"]]        // float f | "center" | "max" -- default: "center"
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "2",
        [
            [ "box_dimensions",                             [60.0, 120.0, 30.0] ],
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chits",
                        [
                            ["type",                        "tokens"],
                            ["compartment_size",            [ 26, 40.0, 20.0] ],
                            ["num_compartments",            [1, 2] ], 
                            ["rotation",                    0 ], 
                            ["position",                    [0,"center"]]        // float f | "center" | "max" -- default: "center"
                        ]
                    ],

                    [   "my chits",
                        [
                            ["type",                        "tokens"],
                            ["compartment_size",            [ 26, 40.0, 20.0] ],
                            ["num_compartments",            [1, 2] ], 
                            ["rotation",                    90 ], 
                            ["position",                    ["max","center"]]        // float f | "center" | "max" -- default: "center"
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a round chit stack box",
        [
            [ "box_dimensions",                             [80.0, 140.0, 30.0] ], 
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack"],
                            ["compartment_size",            [ 25, 40.0, 20.0] ], 
                            ["num_compartments",            [1, 2] ], 
                            ["shape",                       "circle"],              // "circle" | "hex"
                            ["position",                    [0,"center"]],        // float f | "center" | "max" -- default: "center"
                            ["rotation",                   0]
                        ]
                    ],

                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack"],
                            ["compartment_size",            [ 20, 40.0, 20.0] ], 
                            ["num_compartments",            [1, 2] ], 
                            ["shape",                       "circle"],              // "circle" | "hex"
                            ["position",                    ["max","center"]],        // float f | "center" | "max" -- default: "center"
                            ["rotation",                    90 ],
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a hex tile stack box",
        [
            [ "box_dimensions",                             [140.0, 140.0, 30.0] ], 
            [ "enabled",                                    true ],
           [ "lid",                                        false ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack"],
                            ["compartment_size",            [ 20, 40.0, 20.0] ], 
                            ["num_compartments",            [2, 2] ], 
                            ["shape",                       "hex_rotated"],
                            ["rotation",                    0],
                            ["position",                    [0,0]]
                        ]
                    ],
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_compact"],
                            ["compartment_size",            [ 20, 20.0, 20.0] ], 
                            ["num_compartments",            [2, 2] ], 
                            ["shape",                       "hex_rotated"],
                            ["rotation",                    90],
                            ["position",                    ["max","max"]]
                        ]
                    ],
                ]
            ]
        ]
    ],

    [   "a simple box",
        [
            [ "box_dimensions",                             [20.0, 20.0, 12.0] ], 
            [ "enabled",                                    true ],
           [ "lid",                                        1 ],


            [   "components",
                [
                    [   "box",
                        [
                            ["compartment_size",            [ 15, 15.0, 8.0] ], 
                            ["num_compartments",            [1, 1] ], 
                        ]
                    ],
                ]
            ]
        ]
    ],

    [   "a vertical chit stack",
        [
            [ "box_dimensions",                             [40.0, 260.0, 50.0] ], 
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_vertical"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 2] ],
                            ["shape",                       "hex"],
                            ["position",                    [ -12, 0]],
                            ["rotation",                    90]
                        ]
                    ],
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_vertical"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 2] ],
                            ["shape",                       "round"],
                            ["position",                    [ -12, 70]],
                            ["rotation",                    90]
                        ]
                    ],
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_vertical"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 2] ],
                            ["shape",                       "oct"],
                            ["position",                    [ -12, 140]],
                            ["rotation",                    90]
                        ]
                    ],
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_vertical"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 2] ],
                            ["position",                    [ -12, 210]],
                            ["rotation",                    90]
                        ]
                    ],
                                   
                ]
            ]
        ]
    ],    
    [   "a compact chit stack",
        [
            [ "box_dimensions",                             [50.0, 100.0, 50.0] ], 
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_compact"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 1] ],
                            ["position",                    ["center", -1]],
                        ]
                    ],
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_compact"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 1] ],
                            ["position",                    ["center", "max"]],
                            ["rotation",                    180],
                        ]
                    ],
                ]
            ]
        ]
    ],    
    [   "decahedron",
        [
            [ "box_dimensions",                             [140.0, 140.0, 30.0] ], 
            [ "enabled",                                    true ],
           [ "lid",                                        false ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "decahedron"],
                            ["compartment_size",            [ 20, 20.0, 22.0] ], 
                            ["num_compartments",            [2, 2] ], 
                            ["rotation",                    0],
                            ["position",                    [0,0]]
                        ]
                    ],

                ]
            ]
        ]
    ],    
];


MakeAll();
