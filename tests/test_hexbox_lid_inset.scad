// Test: HexBox with inset lid
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "hexbox inset lid",
        [
            [ TYPE, HEXBOX ],
            [ HEXBOX_SIZE_DZ, [80, 30] ],
            [ BOX_COMPONENT, cmp_parms_hex_tile( d=80, dz=28 ) ],
            [ BOX_LID, [
                [ LID_INSET_B, t ],
                [ LID_PATTERN_RADIUS, 10 ],
                [ LID_PATTERN_N1, 6 ],
                [ LID_PATTERN_N2, 6 ],
                [ LID_PATTERN_THICKNESS, 0.5 ],
            ]],
        ]
    ],
];

MakeAll();
