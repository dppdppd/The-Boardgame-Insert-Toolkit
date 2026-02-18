// Test: Bottom cutouts — FTR_CUTOUT_BOTTOM_B and FTR_CUTOUT_BOTTOM_PCT
include <../boardgame_insert_toolkit_lib.4.scad>;

g_b_print_lid = false;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ OBJECT_BOX, [
        [ NAME, "bottom cutout" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE, [
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
            [ FTR_CUTOUT_BOTTOM_B, t ],
        ]],
    ]],
    [ OBJECT_BOX, [
        [ NAME, "bottom cutout 50pct" ],
        [ BOX_SIZE_XYZ, [50, 50, 20] ],
        [ BOX_FEATURE, [
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 46, 18] ],
            [ FTR_CUTOUT_BOTTOM_B, t ],
            [ FTR_CUTOUT_BOTTOM_PCT, 50 ],
        ]],
    ]],
];
MakeAll();
