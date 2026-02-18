// Test: HEX2 compartment shape (corner-down hex) — normal, rotated, vertical
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_BOX, [
        [ NAME, "hex2 normal" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ FTR_SHAPE, HEX2 ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "hex2 rotated" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [20, 20, 18] ],
            [ FTR_SHAPE, HEX2 ],
            [ FTR_SHAPE_ROTATED_B, t ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "hex2 vertical" ],
        [ BOX_SIZE_XYZ, [55, 55, 10] ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [25, 25, 8] ],
            [ FTR_SHAPE, HEX2 ],
            [ FTR_SHAPE_VERTICAL_B, t ],
        ]],
    ]],
];
MakeAll();
