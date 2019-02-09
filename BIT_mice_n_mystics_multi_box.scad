
include <boardgame_insert_toolkit_lib.scad>;


// This is a working example of the Boardgame Insert Toolkit used to create a single large box insert
// for the Z-Man game, Pandemic. It is designed for a printer that can print 290mm x 210mm x 28mm.
// See the two box version for an example of a design for smaller printers.
// 
data =
[
    [   "1",
        [
            [   "box_dimensions",                 [187, 190, 37.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "hearts & cheese & status",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "tokens"],                  // "cards" | "tokens" | "chit_stack" | "chit_stack_vertical" | "" -- default: ""
                            ["compartment_size",            [ 60.0, 60.0, 20.0] ],      // [float, float, float]
                            ["num_compartments",            [1, 3] ],                   // [int, int]
                            ["position",                    [122, 1 ] ],                // [float, float, float]
                            ["label",
                                [
                                    ["text",                     [  ["status"],         // simple string or array representing each compartment
                                                                    ["cheese"],
                                                                    ["health"]]],
                                    ["size",                     4],                    // default 4
                                    ["rotation",                0]                      // 0 | 90 | -90 | 180 -- default = 0
                                ]
                            ]

                        ]
                    ],

                    [   "heroes",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 30.0, 29.5, 35.0] ],
                            ["num_compartments",            [1, 6] ],
                            ["position",                    [1, 1 ] ],
                            ["label",
                                [
                                    ["text",                     "mouse"],
                                    ["size",                     4],
                                ]
                            ]
                        ]
                    ],

                    [   "rats",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 37.0, 29.5, 35.0] ],
                            ["num_compartments",            [1, 6] ],
                            ["position",                    [32, 1 ] ],
                            ["label",
                                [
                                    ["text",                     "rat"],
                                    ["size",                     4],
                                ]
                            ]                            
                        ] 
                    ],

                    [   "centipede",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 51.0, 35.0, 35.0] ],
                            ["num_compartments",            [1, 1] ],
                            ["position",                    [70, 106 ] ],
                            ["label",
                                [
                                    ["text",                     "centipede"],
                                    ["size",                     4],
                                ]
                            ]                            
                        ]
                    ],

                    [   "spider",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 51.0, 40.0, 20.0] ],
                            ["num_compartments",            [1, 1] ],
                            ["position",                    [70, 143 ] ],
                            ["label",
                                [
                                    ["text",                     "spider"],
                                    ["size",                     4],
                                ]
                            ]                            
                        ]
                    ],

                    [   "roaches",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 25.0, 25.0, 10.0] ],
                            ["num_compartments",            [2, 4] ],
                            ["position",                    [70, 1 ] ],
                            ["label",
                                [
                                    ["text",                    "roach"],
                                    ["size",                     4],
                                ]
                            ]                            
                        ]
                    ],

                    
                    // more components here...
                ]
            ],
        ]
    ],

    [   "2",
        [
            [   "box_dimensions",                 [93, 190, 20.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "misc tokens",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "tokens"],
                            ["compartment_size",            [ 42.0, 60.0, 18.0] ],
                            ["num_compartments",            [2, 3] ],
                        ]
                    ],
                ]
            ],
        ]
    ],
    [   "3",
        [
            [   "box_dimensions",                 [95, 190, 18.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [

                    [   "small cards",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "cards"],
                            ["compartment_size",            [ 70.0, 46.0, 12.0] ],
                            ["num_compartments",            [1, 3] ],
                            ["position",                    [ 1, "center" ] ],                       
                        ]
                    ],

                    [   "dice",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "chit_stack"],
                            ["compartment_size",            [ 17.0, 82.0, 17.0] ],
                            ["num_compartments",            [1, 1] ],
                            ["position",                    [-1, "center" ] ],
                            ["label",
                                [
                                    ["text",                     "dice"],
                                    ["size",                     5],
                                    ["rotation",                90],
                                ]
                            ]                            
                        ]
                    ],
 

                    
                    // more components here...
                ]
            ],
        ]
    ],
    [   "4",
        [
            [   "box_dimensions",                 [187, 95, 37.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                        "cards"],                   // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",            [ 90.0, 65.0, 27.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [2, 1] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false

                        ]
                    ],
                ]
            ],
        ]
    ],
    
];


// for printing control.
b_print_lid = true;
b_print_box = true;

b_print_box = "29cm box"; // isolate one box to print

MakeAll();
