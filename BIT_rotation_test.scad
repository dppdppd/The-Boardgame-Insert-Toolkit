
include <boardgame_insert_toolkit_lib.scad>;


data =
[
    [   "a card box",
        [
            [ "box_dimensions",                             [100.0, 100.0, 20.0] ],      // float f -- default:[ 100, 100, 100]
            [ "enabled",                                    true ],

            [   "components",
                [
                    [   "cards",
                        [
                            ["type",                        ""],                   // "cards" | "tokens" | "chit_stack" | "" -- default: ""
                            ["compartment_size",            [ 20, 50.0, 20.0] ],        // float f -- default:[ 10, 10, 10]
                            ["num_compartments",            [1, 1] ],                   // int i -- default: [1, 1]
                            ["enabled",                     true ],                     // true | false
                            ["rotation",                    0 ],                        // 0 | 90 | -90 | 180
                            ["position",                    [0,0]]        // float f | "center" | "max" -- default: "center"
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
