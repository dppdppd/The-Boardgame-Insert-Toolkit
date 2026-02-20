// Test: HexBox stackable — with labeled lid
include <boardgame_insert_toolkit_lib.3.scad>;
include <bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "hexbox stackable",
        [
            [ TYPE, HEXBOX ],
            [ HEXBOX_SIZE_DZ, [100, 40] ],
            [ BOX_STACKABLE_B, t ],
            [ BOX_COMPONENT, cmp_parms_hex_tile( d=100, dz=38, lbl="TILES" ) ],
            [ BOX_LID, lid_parms( radius=12, lbl="HEX STACK" ) ],
        ]
    ],
];

MakeAll();
