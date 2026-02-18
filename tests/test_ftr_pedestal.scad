// Test: Pedestal base — FTR_PEDESTAL_BASE_B (push-down feature for cards)
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_BOX, [
        [ NAME, "pedestal base" ],
        [ BOX_SIZE_XYZ, [45, 45, 15] ],
        [ BOX_FEATURE, [
            [ FTR_COMPARTMENT_SIZE_XYZ, [42, 42, 7] ],
            [ FTR_PEDESTAL_BASE_B, t ],
        ]],
    ]],
];
MakeAll();
