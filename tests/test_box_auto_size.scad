// Test: Auto-calculate BOX_SIZE_XYZ from components when omitted
// Expected: renders correctly sized boxes without explicit BOX_SIZE_XYZ
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    // Single component, centered (default) — simplest auto-size case
    // Expected: box = [43, 33, 21.5] (40+3, 30+3, 20+1.5)
    [ "single_auto",
        [
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [ 40, 30, 20 ] ],
                ]
            ],
        ]
    ],

    // Two centered components — box fits the largest in each dimension
    // Expected: box = [43, 33, 26.5] (max(40,20)+3, max(30,20)+3, max(15,25)+1.5)
    [ "multi_centered_auto",
        [
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [ 40, 30, 15 ] ],
                ]
            ],
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [ 20, 20, 25 ] ],
                ]
            ],
        ]
    ],

    // Grid component — auto-size accounts for num_compartments and padding
    // Component X: 20*2 + 1*2 = 42, Y: 15*3 + 2*1 = 47
    // Expected: box = [45, 50, 11.5] (42+3, 47+3, 10+1.5)
    [ "grid_auto",
        [
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [ 20, 15, 10 ] ],
                    [ FTR_NUM_COMPARTMENTS_XY, [ 2, 3 ] ],
                    [ FTR_PADDING_XY, [ 2, 1 ] ],
                ]
            ],
        ]
    ],
];

MakeAll();
