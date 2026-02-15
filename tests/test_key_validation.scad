// Test: Key validation catches typos and malformed entries
// Expected: renders successfully with BIT: messages in console for bad keys
include <../boardgame_insert_toolkit_lib.4.scad>;
include <../bit_functions_lib.4.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "validation_box",
        [
            [ BOX_SIZE_XYZ, [ 60, 40, 20 ] ],

            // Intentional typos to trigger validation messages
            [ "boz_size",   [ 60, 40, 20 ] ],    // typo: boz_size
            [ "compnent",   [] ],                 // typo: compnent (should be component)

            [ BOX_COMPONENT,
                [
                    [ CMP_COMPARTMENT_SIZE_XYZ, [ 25, 35, 18 ] ],
                    [ CMP_NUM_COMPARTMENTS_XY, [ 2, 1 ] ],

                    // Intentional component-level typo
                    [ "cmp_shapee", "square" ],   // typo: cmp_shapee
                ]
            ],

            [ BOX_LID,
                [
                    [ LID_SOLID_B, true ],

                    // Intentional lid-level typo
                    [ "lid_hight", 3 ],           // typo: lid_hight

                    [ LABEL,
                        [
                            [ LBL_TEXT, "test" ],
                            [ LBL_SIZE, 8 ],

                            // Intentional label-level typo
                            [ "lbl_fontt", "sans" ], // typo: lbl_fontt
                        ]
                    ],
                ]
            ],
        ]
    ],
];

MakeAll();
