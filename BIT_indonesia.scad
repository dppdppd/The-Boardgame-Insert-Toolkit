
include <boardgame_insert_toolkit_lib.scad>;



// determines whether lids are output.
g_b_print_lid = 0;

// determines whether boxes are output.
g_b_print_box = 1; 

// Focus on one box
g_isolated_print_box = "1"; 

// Used to visualize how all of the boxes fit together. 
// Turn off for printing.
g_b_visualization = 0;          

// Makes solid simple lids instead of the honeycomb ones.
// Might be faster to print. Definitely faster to render.
g_b_simple_lids = 0;            


// creates the indentation on the bottom of the box 
//that allows the lid to be put under when in play.
g_b_fit_lid_underneath = 1; 

// total indonesia box interior dimensions: 210 x 300
// 

data =
[
    [   "1",
        [
            [ "box_dimensions", [165, 210, 30.0] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "label",
                [
                    [ "text",   "Indonesia A"],
                    [ "size",   12 ]
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
                            ["compartment_size",    [ 60.0, 92.0, 10.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [-12, 6 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            // ["label",
                            //     [
                            //         ["text",        [   ["status"],         // simple string or array representing each compartment
                            //                             ["cheese"],
                            //                             ["health"]]],
                            //         ["size",        5],                    // default 4
                            //         ["rotation",    0]                      // 0 | 90 | -90 | 180 -- default = 0
                            //     ]
                            // ]

                        ]
                    ],

                    [ "goods chits",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "chit_stack"],
                            ["compartment_size",    [ 17.0, 26, 17.0] ],
                            ["extra_spacing",       [0, 0, 0] ],
                            ["num_compartments",    [6, 2] ],
                            ["position",            ["max", "max" ] ],
                            ["rotation",            0]
                        ]
                    ],


                    [   "money",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "cards"],
                            ["compartment_size",    [ 52.0, 96, 20.0] ],
                            ["num_compartments",    [1, 1] ],
                            ["position",            [-12, "max" ] ],
                            ["rotation",            90 ],
                        ]
                    ],


                    [   "other", // 48,125
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "tokens"],
                            ["compartment_size",    [ 32, 56, 28.0] ],
                            ["num_compartments",    [3, 2] ],
                            ["position",            ["max", 0 ] ],
                            ["rotation",            90],
                        ]
                    ],
                ]
            ],
        ]
    ],  
    

    [   "2",
        [
            [ "box_dimensions", [134, 210, 30.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",        1 ],
            [ "label",
                [
                    [ "text",   "Indonesia B"],
                    [ "size",   12 ]
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
                            ["enabled",             1 ],                     // true | false
                            ["type",                "cards"],                  // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 67.0, 44.0, 24.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 2] ],                   // [int, int]
                            ["position",            [-13, 0 ] ],                // [float, float, float]
                            ["rotation",            90]
                            // ["label",
                            //     [
                            //         ["text",        [   ["status"],         // simple string or array representing each compartment
                            //                             ["cheese"],
                            //                             ["health"]]],
                            //         ["size",        5],                    // default 4
                            //         ["rotation",    0]                      // 0 | 90 | -90 | 180 -- default = 0
                            //     ]
                            // ]

                        ]
                    ],

                    [   "ships",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "chit_stack"],
                            ["compartment_size",    [ 30.5, 42, 22.0] ],
                            ["extra_spacing",       [ 0, 5, 0]],
                            ["num_compartments",    [2, 3] ],
                            ["position",            ["max", "center" ] ],
                            ["rotation",            1],
                            ["label",
                                [
                                    ["text",        "ships"],
                                    ["size",        5],                    // default 4
                                    ["rotation",    1]                      // 0 | 90 | -90 | 180 -- default = 0
                                ]
                            ]
                        ]
                    ],

                    [   "coins", // 20x40x65 = 52000 
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "tokens"],
                            ["compartment_size",    [ 33.0, 65, 26.0] ],
                            ["num_compartments",    [2, 1] ],
                            ["position",            [0, "max" ] ],
                            ["rotation",            -90],
                            ["label",
                                [
                                    ["text",        "coins"],
                                    ["size",        5],                    // default 4
                                    ["rotation",    1]                      // 0 | 90 | -90 | 180 -- default = 0
                                ]
                            ]
                        ]
                    ],

                    [   "wood bits",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "tokens"],
                            ["compartment_size",    [ 67, 50, 26.0] ],
                            ["num_compartments",    [1, 1] ],
                            ["position",            [0, 90 ] ],
                            ["rotation",            0],
                        ]
                    ],

                    
                    // more components here...
                ]
            ],
        ]
    ],      
];


MakeAll();
