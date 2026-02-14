// Test: HexBox without lid
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "hexbox no lid",
        [
            [ TYPE, HEXBOX ],
            [ HEXBOX_SIZE_DZ, [70, 25] ],
            [ BOX_NO_LID_B, t ],
            [ BOX_COMPONENT, [
                [ CMP_COMPARTMENT_SIZE_XYZ, [25, 25, 23] ],
                [ CMP_NUM_COMPARTMENTS_XY, [1, 1] ],
            ]],
        ]
    ],
];

MakeAll();
