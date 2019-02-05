
include <../boardgame_insert_toolkit_lib.scad>;


// This is a working example of the Boardgame Insert Toolkit used to create a single large box insert
// for the Z-Man game, Pandemic. It is designed for a printer that can print 290mm x 210mm x 28mm.
// See the two box version for an example of a design for smaller printers.
// 
data =
[
    [   "card box",
        [
            [ "box_dimensions",                             [100.0, 80.0, 30.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                        ""],              // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",            [ 50, 40.0, 20.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [1,1] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    1],                        // 0 | 1 
                          //  ["position",                    [0,0]]

                        ]
                    ],
                ]
            ]
        ]
    ],

    [   "chits box",
        [
            [ "box_dimensions",                             [118.0, 210.0, 28.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "disease markers",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "chits"],
                            ["compartment_size",            [ 45.0, 45.0, 10.0] ],
                            ["num_compartments",            [1, 4] ],
                            ["position",                    [10, "center"] ],
                        ]
                    ],

                    [   "other bits",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "chits"],
                            ["compartment_size",            [ 40.0, 50.0, 10.0] ],
                            ["num_compartments",            [1, 3] ],
                            ["position",                    [65, "center"] ],
                            ["extra_spacing",               [0, 10] ]
                        ]
                    ]
                ]
            ]
        ]
    ]
];


// for printing control.
b_print_lid = false;
b_print_box = true;

b_print_box = "29cm box"; // isolate one box to print

MakeAll();
