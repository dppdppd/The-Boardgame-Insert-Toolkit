
include <boardgame_insert_toolkit_lib.scad>;


// This is a working example of the Boardgame Insert Toolkit used to create a single large box insert
// for the Z-Man game, Pandemic. It is designed for a printer that can print 290mm x 210mm x 28mm.
// See the two box version for an example of a design for smaller printers.
// 
data =
[
    [   "1",
        [
            [   "box_dimensions",                 [187, 192.5, 37.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "hearts & cheese & status",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "tokens"],
                            ["compartment_size",            [ 60.0, 60.0, 20.0] ],
                            ["num_compartments",            [1, 3] ],
                            ["position",                    [123, 3 ] ],
                        ]
                    ],

                    [   "heroes",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 30.0, 25.0, 35.0] ],
                            ["num_compartments",            [1, 6] ],
                            ["position",                    [0, 3 ] ],
                        ]
                    ],

                    [   "rats",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 35.0, 25.0, 35.0] ],
                            ["num_compartments",            [1, 6] ],
                            ["position",                    [31, 3 ] ],
                        ]
                    ],

                    [   "millipede",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 51.0, 35.0, 35.0] ],
                            ["num_compartments",            [1, 1] ],
                            ["position",                    [69, 108 ] ],
                        ]
                    ],

                    [   "spider",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 51.0, 40.0, 20.0] ],
                            ["num_compartments",            [1, 1] ],
                            ["position",                    [69, 145 ] ],
                        ]
                    ],

                    [   "roaches",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        ""],
                            ["compartment_size",            [ 25.0, 25.0, 10.0] ],
                            ["num_compartments",            [2, 4] ],
                            ["position",                    [69, 3 ] ],
                        ]
                    ],

                    
                    // more components here...
                ]
            ],
        ]
    ],

    [   "2",
        [
            [   "box_dimensions",                 [95, 148, 37.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "misc tokens",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "tokens"],
                            ["compartment_size",            [ 45.0, 70.0, 20.0] ],
                            ["num_compartments",            [2, 2] ],
                            ["position",                    [0, 3 ] ],
                        ]
                    ],
                ]
            ],
        ]
    ],
    [   "3",
        [
            [   "box_dimensions",                 [187, 90, 37.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                        "cards"],                   // "cards" | "chits" | "generic" -- default: "generic"
                            ["compartment_size",            [ 90.0, 65.0, 27.0] ],      // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [2, 1] ],                   // int i -- default: [1, 1]
                            ["position",                    [ 0, 0 ] ],          // float f | "center" | "max" -- default: "center"
                            ["extra_spacing",               [0.0, 0.0] ],                   // float f
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    0 ],                        // 0 | 1 | -1

                        ]
                    ],
                ]
            ],
        ]
    ],
    [   "4",
        [
            [   "box_dimensions",                 [95, 134, 37.0] ],                       // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [

                    [   "small cards",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "cards"],
                            ["compartment_size",            [ 70.0, 46.0, 12.0] ],
                            ["num_compartments",            [1, 2] ],
                            ["position",                    [ 0, "center" ] ],
                        ]
                    ],

                    [   "dice",
                        [
                            ["enabled",                     true ],                     // true | false
                            ["type",                        "chit_stack"],
                            ["compartment_size",            [ 16.0, 80.0, 16.0] ],
                            ["num_compartments",            [1, 1] ],
                            ["position",                    [-1, "center" ] ],
                        ]
                    ],
 

                    
                    // more components here...
                ]
            ],
        ]
    ],
];


// for printing control.
b_print_lid = false;
b_print_box = true;

b_print_box = "29cm box"; // isolate one box to print

MakeAll();
