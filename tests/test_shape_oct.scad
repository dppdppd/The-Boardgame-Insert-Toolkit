// Test: OCT compartment shape — normal, rotated, vertical
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_BOX, [
        [ NAME, "oct normal" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ FTR_SHAPE, OCT ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "oct rotated" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ FTR_SHAPE, OCT ],
            [ FTR_SHAPE_ROTATED_B, t ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "oct vertical" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ FTR_SHAPE, OCT ],
            [ FTR_SHAPE_VERTICAL_B, t ],
        ]],
    ]],
];
MakeAll();
