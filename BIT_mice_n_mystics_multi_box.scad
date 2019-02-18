
include <boardgame_insert_toolkit_lib.scad>;


// for printing control.
g_b_print_lid = 1; // determines whether lids are constructed.
g_b_print_box = 1; // determines whether boxes are constructed.

g_isolated_print_box = ""; // easy way to isolate one box to print

g_b_visualization = 0;          // used to visualize how all of the boxes fit together. Turn off for printing.
g_b_simple_lids = 0;            // solid simple lids instead of the honeycomb ones. Might be faster to print. Definitely faster to render.

g_b_fit_lid_underneath = 1; // creates the indentation on the bottom of the box that allows the lid to be put under when in play. Requires support.

// 285 x 285
// 
data =
[
    [   "1",
        [
            [ "box_dimensions", [183, 190, 38.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",        1 ],
            [ "label",
                [
                    [ "text",   "Mice & Mystics"],
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
                    [   "hearts & cheese & status",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                "tokens"],                  // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 57.0, 60.0, 20.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 3] ],                   // [int, int]
                            ["position",            [122, 1 ] ],                // [float, float, float]
                            ["label",
                                [
                                    ["text",        [   ["status"],         // simple string or array representing each compartment
                                                        ["cheese"],
                                                        ["health"]]],
                                    ["size",        5],                    // default 4
                                    ["rotation",    0]                      // 0 | 90 | -90 | 180 -- default = 0
                                ]
                            ]

                        ]
                    ],

                    [   "heroes",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                ""],
                            ["compartment_size",    [ 30.0, 29.5, 32.0] ],
                            ["num_compartments",    [1, 6] ],
                            ["position",            [1, 1 ] ],
                        ]
                    ],

                    [   "rats",
                        [
                            ["enabled",             true ],                     // true | false
                            ["type",                ""],
                            ["compartment_size",    [ 37.0, 29.5, 32.0] ],
                            ["num_compartments",    [1, 6] ],
                            ["position",            [32, 1 ] ],                          
                        ] 
                    ],

                    [   "centipede",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                ""],
                            ["compartment_size",    [ 51.0, 35.0, 36.0] ],
                            ["num_compartments",    [1, 1] ],
                            ["position",            [70, 106 ] ],                       
                        ]
                    ],

                    [   "spider",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                ""],
                            ["compartment_size",    [ 51.0, 40.0, 17.0] ],
                            ["num_compartments",    [1, 1] ],
                            ["position",            [70, 143 ] ],                           
                        ]
                    ],

                    [   "roaches",
                        [
                            ["enabled",             1 ],                     // true | false
                            ["type",                ""],
                            ["compartment_size",    [ 25.0, 25.0, 7.0] ],
                            ["num_compartments",    [2, 4] ],
                            ["position",            [70, 1 ] ],                           
                        ]
                    ],

                    
                    // more components here...
                ]
            ],
        ]
    ],

    [   "2",
        [
            [ "box_dimensions",     [93, 183, 17] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",            true ],
      //      [ "thin_lid",           true ],                                 // intended for gluing on bottom of upper container
            [ "label",
                [
                    [ "text",       "tokens"],
                    [ "size",       12 ],
                    [ "rotation",   -90 ],    

                ]
            ],
            [ "visualization",
                [
                    [ "position",   [0,191,0] ],
                    [ "rotation",   90 ],
                ]
            ],    

            [   "components",
                [
                    [   "misc tokens",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "tokens"],
                            ["compartment_size",            [ 42.0, 59.0, 15.0] ],
                            ["num_compartments",            [2, 3] ],
                        ]
                    ],
                ]
            ],
        ]
    ],
    [   "3",
        [
            [ "box_dimensions",     [93, 183, 18.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",            1 ],
            [ "label",
                [
                    [ "text",       "cards & dice"],
                    [ "size",       12 ],
                    [ "rotation",   -90 ], 
                ]
            ],
            [ "visualization",
                [
                    [ "position",   [0, 191, 20 ] ],
                    [ "rotation",   90 ],
                ]
            ],    

            [   "components",
                [

                    [   "small cards",
                        [
                            ["enabled",             true ],                     // true | false
                            ["type",                "cards"],
                            ["compartment_size",    [ 71.0, 47.0, 12.0] ],
                            ["num_compartments",    [1, 3] ],
                            ["position",            [ 0, "center" ] ],                       
                        ]
                    ],

                    [   "dice",
                        [
                            ["enabled",             true ],                     // true | false
                            ["type",                "chit_stack"],
                            ["compartment_size",    [ 17.0, 82.0, 17.0] ],
                            ["num_compartments",    [1, 1] ],
                            ["position",            [ "max", "center" ] ],                         
                        ]
                    ]
                ]
            ]
        ]
    ],
    [   "4",
        [
            [ "box_dimensions",     [190, 100, 27.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",            1 ],
   //         [ "thin_lid",           true ],                                 // intended for gluing on bottom of upper container
            [ "label",
                [
                    [ "text",       "cards"],
                    [ "size",       12 ],
                    [ "rotation",   -90 ], 
                ]
            ],
            [ "visualization",
                [
                    [ "position",   [184,0, 0] ],
                    [ "rotation",   90 ],
                ]
            ],       

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                "cards"],                   // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",    [ 90.0, 65.0, 22.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",    [2, 1] ],                   // int i -- default: [1, 1]
                            ["enabled",             true ],                     // true | false

                        ]
                    ]
                ]
            ]
        ]
    ],

    [   "5",
        [
            [ "box_dimensions",     [100, 190, 8] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",            1 ],
            [ "label",
                [
                    [ "text",   "characters"],
                    [ "size",   12 ],
                ]
            ],
            [ "visualization",
                [
                    [ "position",   [184,0,30] ],
                    [ "rotation",   0 ],
                ]
            ],      

            [   "components",
                [
                    [   "player cards",
                        [
                            ["type",                "cards"],                   // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",    [ 96.0, 173.0, 7.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",    [1, 1] ],                   // int i -- default: [1, 1]
                            ["enabled",             true ],                     // true | false

                        ]
                    ],
                ]
            ],
        ]
    ],

[   "6",
        [
            [ "box_dimensions",     [100, 93, 38.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",            1 ],
           // [ "type",               "spacer" ],

            [ "visualization",
                [
                    [ "position",   [184,191,0] ],
                    [ "rotation",   0 ],
                ]
            ],     
            [   "components",
                [
                    [   "box",
                        [
                            ["type",                ""],                   // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",    [ 96.0, 89.0, 36.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",    [1, 1] ],                   // int i -- default: [1, 1]
                            ["enabled",             true ],                     // true | false

                        ]
                    ],
                ]
            ], 
        ]
    ],    
    
];


MakeAll();
