// Test: Compartment grids — various NUM_COMPARTMENTS_XY configurations
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_BOX, [
        [ NAME, "1x1 grid" ],
        [ BOX_SIZE_XYZ, [30, 30, 15] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [1, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [26, 26, 13] ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "3x2 grid" ],
        [ BOX_SIZE_XYZ, [70, 50, 15] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [3, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 13] ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "6x1 row" ],
        [ BOX_SIZE_XYZ, [140, 30, 15] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [6, 1] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 26, 13] ],
        ]],
    ]],
];
MakeAll();
