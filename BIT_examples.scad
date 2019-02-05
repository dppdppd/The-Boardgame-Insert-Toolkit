
include <boardgame_insert_toolkit_lib.scad>;


// This is a working example of the Boardgame Insert Toolkit used to create a single large box insert
// for the Z-Man game, Pandemic. It is designed for a printer that can print 290mm x 210mm x 28mm.
// See the two box version for an example of a design for smaller printers.
// 
data =
[
    [   "a card box",
        [
            [ "box_dimensions",                             [90.0, 120.0, 30.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                        "cards"],              // "cards" | "chits" | "chit_stack" | "" -- default: ""
                            ["compartment_size",            [ 40, 40.0, 20.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [2, 2] ], 
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a chit box",
        [
            [ "box_dimensions",                             [60.0, 120.0, 30.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    false ],

            [   "components",
                [
                    [   "my chits",
                        [
                            ["type",                        "chits"],              // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",            [ 20, 40.0, 20.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [2, 2] ], 
                        ]
                    ],
                ]
            ]
        ]
    ],
    [   "a chit stack box",
        [
            [ "box_dimensions",                             [60.0, 120.0, 30.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "my chit stack",
                        [
                            ["type",                        "chit_stack"],              // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",            [ 20, 40.0, 20.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [2, 2] ], 
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

MakeAll();
