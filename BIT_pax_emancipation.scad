
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
g_b_fit_lid_underneath = 0; 

// total indonesia box interior dimensions: 115 x 115 x 50
// 

data =
[
    [   "1",
        [
            [ "box_dimensions", [115, 115, 25.0] ],                       // float f -- default:[ 100, 100, 100]

            [ "enabled",        1 ],
            [ "thin_lid",       true ],
            [ "label",
                [
                    [ "text",   "PAX EMANCIPATION"],
                    [ "size",   8 ]
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
                    [   "meeples",
                        [
                            ["enabled",             0 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 98.0, 38.0, 24.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, 0 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],

                    [   "agents",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "tokens"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 55.0, 74.0, 24.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, 0 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "AGENTS"],
                                    [ "size",   4 ]
                                ]],
                        ]
                    ],

                    [   "meeples",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 55.0, 24.0, 24.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 3] ],                   // [int, int]
                            ["position",            ["max", 0] ],                // [float, float, float]
                            ["rotation",            -90 ],
                            ["label",               
                                [
                                    [ "text",   "MEEPLES"],
                                    [ "size",   4 ]
                                ]],
                        ]
                    ],

                    [   "ships",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 51.0, 15.0, 24.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, "max" ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "SHIPS"],
                                    [ "size",   4 ]
                                ]],
                        ]
                    ],

                    [   "tokens",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                "chit_stack"],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["shape",               "round"],
                            ["compartment_size",    [ 65.0, 15.0, 15.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, 75 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],

                    [   "cubes",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["label",               
                                [
                                    [ "text",   "CUBES"],
                                    [ "size",   4 ]
                                ]],
                            ["shape",               "square"],
                            ["compartment_size",    [ 30.0, 15.0, 12.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            ["max", "max" ] ],                // [float, float, float]
                            ["rotation",            90 ],
                        ]
                    ],
                ]
            ]     
        ]
    ],

    [   "2",
        [
            [ "box_dimensions", [26, 115, 25.0] ],                       // float f -- default:[ 100, 100, 100]

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
                    [   "tiles",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 22.0, 76.0, 24.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, 0 ] ],                // [float, float, float]
                            ["rotation",            0 ],
                            ["label",               
                                [
                                    [ "text",   "TILES"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]],
                        ]
                    ],

                    [   "dice",
                        [
                            ["enabled",             1 ],                        // true | false
                            ["type",                ""],                   // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",    [ 22.0, 34.0, 24.0] ],      // [float, float, float]
                            ["num_compartments",    [1, 1] ],                   // [int, int]
                            ["position",            [0, 77 ] ],                // [float, float, float]
                            ["rotation",            90 ],
                            ["label",               
                                [
                                    [ "text",   "DICE & E"],
                                    [ "size",   4 ],
                                    [ "rotation", 90]
                                ]],
                        ]
                    ],


                ]
            ],            
        ]
    ],  
    
];


MakeAll();
