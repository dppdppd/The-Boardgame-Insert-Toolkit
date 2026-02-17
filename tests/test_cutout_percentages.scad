// Test: Cutout size controls — height, depth, width percentages
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "small cutout",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
                    [ FTR_CUTOUT_SIDES_4B, [t, t, t, t] ],
                    [ FTR_CUTOUT_HEIGHT_PCT, 50 ],
                    [ FTR_CUTOUT_DEPTH_PCT, 30 ],
                    [ FTR_CUTOUT_WIDTH_PCT, 50 ],
                ]
            ]
        ]
    ],
    [ "full width cutout",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE,
                [
                    [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 12] ],
                    [ FTR_CUTOUT_SIDES_4B, [t, t, f, f] ],
                    [ FTR_CUTOUT_HEIGHT_PCT, 100 ],
                    [ FTR_CUTOUT_DEPTH_PCT, 50 ],
                    [ FTR_CUTOUT_WIDTH_PCT, 100 ],
                ]
            ]
        ]
    ],
];

MakeAll();
