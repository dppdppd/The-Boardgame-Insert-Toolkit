// Test: HexBox with box side labels and lid labels
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "hexbox labels",
        [
            [ TYPE, HEXBOX ],
            [ HEXBOX_SIZE_DZ, [90, 35] ],
            [ BOX_COMPONENT, cmp_parms_hex_tile( d=90, dz=33, lbl="HEX" ) ],
            [ LABEL, [
                [ LBL_TEXT, "FRONT" ],
                [ LBL_SIZE, 8 ],
                [ LBL_PLACEMENT, FRONT ],
            ]],
            [ BOX_LID, [
                [ LID_SOLID_B, t ],
                [ LID_INSET_B, t ],
                [ LID_HEIGHT, 1.5 ],
                [ LABEL, [
                    [ LBL_TEXT, "HEX LABEL" ],
                    [ LBL_SIZE, AUTO ],
                ]],
            ]],
        ]
    ],
];

MakeAll();
