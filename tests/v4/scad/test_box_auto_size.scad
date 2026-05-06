// Test: Auto-calculate BOX_SIZE_XYZ from components when omitted
// Expected: renders correctly sized boxes without explicit BOX_SIZE_XYZ
include <../../../release/lib/boardgame_insert_toolkit_lib.4.scad>;

data = [
    [ G_PRINT_LID_B, true ],
    [ G_PRINT_BOX_B, true ],
    [ G_ISOLATED_PRINT_BOX, "" ],
    // Single component, centered (default) — simplest auto-size case
    // Expected: box = [44, 34, 22] (40+4, 30+4, 20+2)
    [ OBJECT_BOX,
        [ NAME, "single_auto" ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [40, 30, 20] ],
        ],
    ],
    // Two centered components — box fits the largest in each dimension
    // Expected: box = [44, 34, 27] (max(40,20)+4, max(30,20)+4, max(15,25)+2)
    [ OBJECT_BOX,
        [ NAME, "multi_centered_auto" ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [40, 30, 15] ],
        ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 25] ],
        ],
    ],
    // Grid component — auto-size accounts for num_compartments and padding
    // Component X: 20*2 + 1*2 = 42, Y: 15*3 + 2*1 = 47
    // Expected: box = [46, 51, 12] (42+4, 47+4, 10+2)
    [ OBJECT_BOX,
        [ NAME, "grid_auto" ],
        [ BOX_FEATURE,
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 15, 10] ],
            [ FTR_NUM_COMPARTMENTS_XY, [2, 3] ],
            [ FTR_PADDING_XY, [2, 1] ],
        ],
    ],
];
Make(data);
