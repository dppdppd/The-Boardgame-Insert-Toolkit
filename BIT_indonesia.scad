
include <boardgame_insert_toolkit_lib.scad>;


// for printing control.
g_b_print_lid = 1; // determines whether lids are constructed.
g_b_print_box = 1; // determines whether boxes are constructed.

g_isolated_print_box = "2"; // easy way to isolate one box to print

g_b_visualization = 0;          // used to visualize how all of the boxes fit together. Turn off for printing.
g_b_simple_lids = 0;            // solid simple lids instead of the honeycomb ones. Might be faster to print. Definitely faster to render.

g_b_fit_lid_underneath = 1; // creates the indentation on the bottom of the box that allows the lid to be put under when in play. Requires support.

// 210 x 300
// 
data =
[
    [   "1",
        [
            [ "box_dimensions", [160, 210, 30.0] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "label",
                [
                    [ "text",   "1"],
                    [ "size",   14 ]
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
                            ["compartment_size",    [ 58.0, 90.0, 8.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, -13 ] ],                // [float, float, float]
                           // ["rotation",            90 ],
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

                    [   "goods chits",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "chit_stack"],
                            ["compartment_size",    [ 15.0, 25, 15.0] ],
                            ["num_compartments",    [6, 2] ],
                            ["position",            [60, 0 ] ],
                            ["rotation",            0]
                        ]
                    ],

                    [   "money",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "cards"],
                            ["compartment_size",    [ 50.0, 94, 20.0] ],
                            ["num_compartments",    [1, 1] ],
                            ["position",            ["max", 105 ] ],
                            ["rotation",            180 ],
                            ["label",
                                [
                                    ["text",        "money"],
                                    ["size",        5],                    // default 4
                                    ["rotation",    1]                      // 0 | 90 | -90 | 180 -- default = 0
                                ]
                            ]
                        ]
                    ],

                    [   "other",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "tokens"],
                            ["compartment_size",    [ 33.7, 50, 28.0] ],
                            ["num_compartments",    [3, 2] ],
                            ["position",            [0, "max" ] ],
                            ["rotation",            90],
                        ]
                    ],

                    
                    // more components here...
                ]
            ],
        ]
    ],  
    

    [   "2",
        [
            [ "box_dimensions", [138, 210, 30.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",        1 ],
            [ "label",
                [
                    [ "text",   "2"],
                    [ "size",   14 ]
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
                            ["compartment_size",    [ 64.0, 44.0, 22.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 2] ],                   // [int, int]
                            ["position",            [-6, 0 ] ],                // [float, float, float]
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
                            ["compartment_size",    [ 30.0, 42, 22.0] ],
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

                    [   "coins",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "tokens"],
                            ["compartment_size",    [ 35.0, 65, 26.0] ],
                            ["num_compartments",    [2, 1] ],
                            ["position",            [0, "max" ] ],
                            ["rotation",            90],
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
                            ["compartment_size",    [ 71, 50, 26.0] ],
                            ["num_compartments",    [1, 1] ],
                            ["position",            [0, 90 ] ],
                            ["rotation",            1],
                        ]
                    ],

                    
                    // more components here...
                ]
            ],
        ]
    ],      
];


MakeAll();
