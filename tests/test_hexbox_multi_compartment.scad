// Test: HexBox with multiple compartments and pedestal
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "hexbox multi cmp",
        [
            [ TYPE, HEXBOX ],
            [ HEXBOX_SIZE_DZ, [100, 40] ],
            [ BOX_COMPONENT, [
                [ CMP_COMPARTMENT_SIZE_XYZ, [20, 20, 35] ],
                [ CMP_NUM_COMPARTMENTS_XY, [2, 2] ],
                [ CMP_PEDESTAL_BASE_B, t ],
                [ CMP_SHAPE, ROUND ],
            ]],
            [ BOX_LID, lid_parms( radius=10 ) ],
        ]
    ],
];

MakeAll();
