// Test: HexBox with side and corner cutouts
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "hexbox cutouts",
        [
            [ TYPE, HEXBOX ],
            [ HEXBOX_SIZE_DZ, [80, 35] ],
            [ BOX_COMPONENT, [
                [ CMP_COMPARTMENT_SIZE_XYZ, [30, 30, 33] ],
                [ CMP_NUM_COMPARTMENTS_XY, [1, 1] ],
                [ CMP_CUTOUT_SIDES_4B, [t, f, t, f] ],
                [ CMP_CUTOUT_CORNERS_4B, [t, t, f, f] ],
            ]],
            [ BOX_LID, lid_parms( radius=8 ) ],
        ]
    ],
];

MakeAll();
