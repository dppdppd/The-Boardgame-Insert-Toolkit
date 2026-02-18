// Test: Stackable boxes — BOX_STACKABLE_B
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_BOX, [
        [ NAME, "stackable box" ],
        [ BOX_SIZE_XYZ, [50, 50, 15] ],
        [ BOX_STACKABLE_B, t ],
        [ BOX_LID, [
            [ LID_SOLID_B, t ],
        ]],
        [ BOX_FEATURE, [
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 13] ],
        ]],
    ]],
];
MakeAll();
