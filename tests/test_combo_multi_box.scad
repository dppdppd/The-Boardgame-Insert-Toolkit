// BITGUI
include <boardgame_insert_toolkit_lib.4.scad>;
include <bit_functions_lib.4.scad>;
// Test: Integration — multiple boxes rendered together with different features
include <../boardgame_insert_toolkit_lib.4.scad>;
include <../bit_functions_lib.4.scad>;
g_default_font = "Liberation Sans:style=Regular";
g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";
data = [
    [ "simple solid lid", [
        [ BOX_SIZE_XYZ, [45, 45, 15] ],
        [ BOX_LID, lid_parms_solid() ],
        [ BOX_FEATURE, [
            [ FTR_COMPARTMENT_SIZE_XYZ, [42, 42, 13] ],
        ]],
    ]],
    [ "round compartments pattern lid", [
        [ BOX_SIZE_XYZ, [60, 60, 20] ],
        [ BOX_LID, lid_parms(radius =6, lbl ="COINS") ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [2, 2] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [25, 25, 18] ],
            [ FTR_SHAPE, ROUND ],
        ]],
    ]],
    [ "fillet with cutouts", [
        [ BOX_SIZE_XYZ, [50, 80, 15] ],
        [ BOX_LID, lid_parms_solid() ],
        [ BOX_FEATURE, [
            [ FTR_NUM_COMPARTMENTS_XY, [1, 3] ],
            [ FTR_COMPARTMENT_SIZE_XYZ, [46, 22, 10] ],
            [ FTR_SHAPE, FILLET ],
            [ FTR_CUTOUT_SIDES_4B, [t, t, f, f] ],
        ]],
    ]],
];
MakeAll();