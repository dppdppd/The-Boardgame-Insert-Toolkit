// Test: Helper functions — lid_parms() and lid_parms_solid()
include <../boardgame_insert_toolkit_lib.4.scad>;
include <../bit_functions_lib.4.scad>;
g_default_font = "Liberation Sans:style=Regular";

g_b_print_lid = true;
g_b_print_box = true;
g_isolated_print_box = "";

data = [
    [ "lid_parms helper",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE, ftr_parms(dx=46, dy=46, dz=18) ],
            [ BOX_LID, lid_parms( radius=8, lbl="PATTERN", font="Arial:style=Bold", size=10 ) ],
        ]
    ],
    [ "lid_parms_solid helper",
        [
            [ BOX_SIZE_XYZ, [50, 50, 20] ],
            [ BOX_FEATURE, ftr_parms(dx=46, dy=46, dz=18) ],
            [ BOX_LID, lid_parms_solid() ],
        ]
    ],
];

MakeAll();
