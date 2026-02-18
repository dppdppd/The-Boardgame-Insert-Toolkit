// Test: Custom lid height — LID_HEIGHT
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_BOX, [
        [ NAME, "tall lid" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID, [
            [ LID_HEIGHT, 15 ],
            [ LID_PATTERN_RADIUS, 8 ],
        ]],
        [ BOX_FEATURE, [
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "short lid" ],
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID, [
            [ LID_HEIGHT, 3 ],
            [ LID_SOLID_B, t ],
        ]],
        [ BOX_FEATURE, [
            [ FTR_COMPARTMENT_SIZE_XYZ, [56, 56, 18] ],
        ]],
    ]],
];
MakeAll();
