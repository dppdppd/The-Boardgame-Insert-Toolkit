
include <boardgame_insert_toolkit_lib.scad>;


data =
[
    [   "a card box",
        [
            [ "box_dimensions",                             [90.0, 120.0, 30.0] ],      // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                        "cards"],                   // "cards" | "tokens" | "chit_stack" | "" -- default: ""
                            ["compartment_size",            [ 40, 40.0, 20.0] ],        // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [2, 2] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    0 ],                        // 0 | 1
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
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a round chit stack box",
        [
            [ "box_dimensions",                             [60.0, 120.0, 30.0] ], 
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
            [ "box_dimensions",                             [60.0, 120.0, 30.0] ], 
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
            [ "box_dimensions",                             [80.0, 80.0, 50.0] ], 
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack_vertical"],
                            ["compartment_size",            [ 30, 30.0, 30.0] ], 
                            ["num_compartments",            [1, 1] ],
                            ["shape",                       "hex"],
                        ]
                    ],
                ]
            ]
        ]
    ],    
];


// for printing control.
b_print_lid = true;
b_print_box = true;

//b_print_box = "a vertical chit stack"; // isolate one box to print

MakeAll();
