// Test: HexBox lid with pattern and stripes
include <../boardgame_insert_toolkit_lib.3.scad>;
include <../bit_functions_lib.3.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "hexbox lid pattern",
        [
            [ TYPE, HEXBOX ],
            [ HEXBOX_SIZE_DZ, [80, 25] ],
            [ BOX_COMPONENT, cmp_parms_hex_tile( d=80, dz=23 ) ],
            [ BOX_LID, [
                [ LID_PATTERN_RADIUS, 8 ],
                [ LID_PATTERN_N1, 6 ],
                [ LID_PATTERN_N2, 6 ],
                [ LID_PATTERN_THICKNESS, 0.6 ],
            ]],
        ]
    ],
];

MakeAll();
