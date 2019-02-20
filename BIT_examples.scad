
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

data =
[
    [   "a card box",
        [
            [ "box_dimensions",                             [150.0, 150.0, 30.0] ],      // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                        "cards"],                   // "cards" | "tokens" | "chit_stack" | "" -- default: ""
                            ["compartment_size",            [ 40, 40.0, 20.0] ],        // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [2, 2] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    90 ],                       
                            ["position",                    ["center","center"]]        // float f | "center" | "max" -- default: "center"
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a generic token box",
        [
            [ "box_dimensions",                             [60.0, 120.0, 30.0] ],
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chits",
                        [
                            ["type",                        "tokens"],
                            ["compartment_size",            [ 26, 40.0, 20.0] ],
                            ["num_compartments",            [2, 2] ], 
                            ["rotation",                    90 ], 
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a round chit stack box",
        [
            [ "box_dimensions",                             [60.0, 140.0, 30.0] ], 
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack"],
                            ["compartment_size",            [ 20, 40.0, 20.0] ], 
                            ["num_compartments",            [2, 2] ], 
                            ["shape",                       "circle"],              // "circle" | "hex"
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a hex tile stack box",
        [
            [ "box_dimensions",                             [60.0, 140.0, 30.0] ], 
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack"],
                            ["compartment_size",            [ 20, 40.0, 20.0] ], 
                            ["num_compartments",            [2, 2] ], 
                            ["shape",                       "hex"],
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

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        ""],
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
            [ "box_dimensions",                             [40.0, 40.0, 50.0] ], 
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_vertical"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 1] ],
                            ["shape",                       "hex"],
                            ["position",                    ["center", -10]],
                        ]
                    ],
                ]
            ]
        ]
    ],    
];


MakeAll();
