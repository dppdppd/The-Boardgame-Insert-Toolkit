// Test: Component rotation — ROTATION on BOX_FEATURE
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "rotated component",
        [
            [ BOX_SIZE_XYZ, [110, 180, 22] ],
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [22, 60, 20] ],
                    [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
                    [ FTR_PADDING_XY, [10, 12] ],
                    [ ROTATION, 5 ],
                    [ POSITION_XY, [CENTER, CENTER] ],
                ]
            ],
        ]
    ],
];

MakeAll();
